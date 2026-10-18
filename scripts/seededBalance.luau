--!strict
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local D = require("./models/DiscoveryExperiment")
local Runner = require("./models/BalanceRunner")
local Scenarios = require("./balanceScenarios")
local COUNT = 100000
local MASTER = 20261018
local selectedScenario = process.args[1]
local selectedRun = if process.args[2] then tonumber(process.args[2]) else nil
assert(
	not process.args[2]
		or (selectedRun and selectedRun >= 1 and selectedRun <= COUNT and selectedRun % 1 == 0),
	"invalid run index"
)

local function seedFor(scenario: number, run: number): number
	local seed = (MASTER + scenario * 1000003 + run * 104729) % 2147483646 + 1
	for _ = 1, 3 do
		seed = D.uniform(seed)
	end
	return seed
end

local function quantiles(values: { number }): any
	table.sort(values)
	local out = {}
	for _, q in { 0.5, 0.9, 0.99 } do
		local index = math.ceil(#values * q)
		out[tostring(q)] = if values[index] and values[index] < math.huge
			then values[index]
			else "not reached"
	end
	return out
end

local function timeAt(segments: { any }, unit: number): (number, number)
	local lo, hi = 1, #segments
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		local s = segments[mid]
		if s.acceptedFinish < unit then
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	local s = segments[lo]
	assert(s and s.rate > 0, "unmapped work unit")
	local elapsed = (unit - s.acceptedStart) / s.rate
	return s.start + elapsed, s.onlineStart + elapsed
end

fs.writeDir("build/balance/seeded")
local revision = process.exec("git", { "rev-parse", "HEAD" }).stdout:gsub("%s+$", "")
local dirty = process.exec("git", { "status", "--porcelain" }).stdout ~= ""
local summary = {}
for scenarioIndex, s in Scenarios.all() do
	if selectedScenario and s.id ~= selectedScenario then
		continue
	end
	local result = Runner.run(s)
	local maxUnits = math.floor(result.totals.accepted + 1e-8)
	local originCalendar, originOnline = timeAt(result.segments, 1)
	local records =
		{ "run,seed,policy,first_unit,calendar_seconds,online_seconds,censored,archives,failures" }
	for _, guaranteed in { true, false } do
		local calendars, onlines = {}, {}
		local censored = 0
		for run = selectedRun or 1, selectedRun or COUNT do
			local seed = seedFor(scenarioIndex, run)
			local state = D.new(seed)
			local awards = D.advance(state, maxUnits, guaranteed)
			local first = awards[1]
			local calendar, online = math.huge, math.huge
			if first then
				calendar, online = timeAt(result.segments, first)
				calendar -= originCalendar
				online -= originOnline
			else
				censored += 1
			end
			table.insert(calendars, calendar)
			table.insert(onlines, online)
			table.insert(
				records,
				string.format(
					"%d,%d,%s,%s,%s,%s,%s,%d,%d",
					run,
					seed,
					if guaranteed then "guaranteed" else "pure-control",
					tostring(first or ""),
					if first then string.format("%.9f", calendar) else "",
					if first then string.format("%.9f", online) else "",
					tostring(not first),
					state.archives,
					state.failures
				)
			)
		end
		table.insert(summary, {
			scenario = s.id,
			policy = if guaranteed then "guaranteed" else "pure-control",
			n = if selectedRun then 1 else COUNT,
			horizon = s.horizon,
			eligible = maxUnits,
			censored = censored,
			calendar = quantiles(calendars),
			online = quantiles(onlines),
		})
	end
	fs.writeFile(
		"build/balance/seeded/"
			.. s.id
			.. (if selectedRun then "-run" .. selectedRun else "")
			.. ".csv",
		table.concat(records, "\n") .. "\n"
	)
	print(s.id, "seeded complete")
end
assert(#summary > 0, "unknown scenario")
-- Independent work-distribution validation, no production assumptions.
local work = {}
for _, guaranteed in { true, false } do
	local values = {}
	local sum, capped = 0, 0
	for run = 1, COUNT do
		local state = D.new(seedFor(100, run))
		local first = math.min(state.nextNatural, if guaranteed then 200000 else math.huge)
		table.insert(values, first)
		sum += first
		if first == 200000 then
			capped += 1
		end
	end

	for _, threshold in { 50000, 100000, 199999, 200000, 400000 } do
		local observed = 0
		for _, value in values do
			if value <= threshold then
				observed += 1
			end
		end
		local expectedCdf = if guaranteed and threshold >= 200000
			then 1
			else 1 - (1 - 0.00001) ^ threshold
		assert(
			math.abs(observed / COUNT - expectedCdf) < 0.005148,
			"empirical work CDF outside diagnostic band"
		)
	end
	local expected = if guaranteed then (1 - (1 - 0.00001) ^ 200000) / 0.00001 else 100000
	assert(math.abs(sum / COUNT - expected) < 1500, "work mean differs >1.5k units")
	table.insert(work, {
		policy = if guaranteed then "guaranteed" else "pure-control",
		mean = sum / COUNT,
		expected = expected,
		quantiles = quantiles(values),
		atGuarantee = capped,
	})
end
local manifest = {
	schemaVersion = 1,
	modelVersion = "natural-stream-geometric-v1",
	balanceVersion = "D011-D012-experimental-v1",
	revision = revision,
	dirty = dirty,
	lune = process.exec("lune", { "--version" }).stdout:gsub("%s+$", ""),
	command = "lune run scripts/seededBalance.luau" .. (if selectedScenario
		then " " .. selectedScenario
		else "") .. (if selectedRun then " " .. selectedRun else ""),
	masterSeed = MASTER,
	count = COUNT,
	seedDerivation = "(master+scenarioIndex*1000003+run*104729)%2147483646+1; 3 Park-Miller advances",
	algorithm = "Park-Miller 16807 mod 2147483647; inverse geometric floor(log(1-u)/log(1-p))+1; absolute natural unit stream",
	p = 0.00001,
	H = 200000,
	scenarios = Scenarios.all(),
	summary = summary,
	work = work,
	method = "nearest rank ceil(q*N), all runs; censored as infinity, never omitted; times interpolate constant accepted-rate segments within each step; 99% DKW CDF band +/-0.005148 (ideal independent draws; PRNG uncertainty not covered)",
}
fs.writeFile(
	"build/balance/seeded/"
		.. (if selectedScenario then selectedScenario else "manifest")
		.. (if selectedRun then "-run" .. selectedRun else "")
		.. ".json",
	serde.encode("json", manifest, true) .. "\n"
)
print(serde.encode("json", work, true))
