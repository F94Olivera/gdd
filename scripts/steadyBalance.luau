--!strict
-- Constant sustained throughput control, independent of startup/economic trajectory.
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local D = require("./models/DiscoveryExperiment")
local M = require("./models/BalanceMetrics")
local process = require("@lune/process")
local COUNT = 100000
local HORIZON = 20000000
local output = {}
fs.writeDir("build/balance")
local records =
	{ "run,seed,policy,first_unit,gap2_units,rank5_unit,rank15_unit,rank40_unit,rank100_unit" }
for _, guaranteed in { true, false } do
	local metrics = { first = {}, gap2 = {}, rank5 = {}, rank15 = {}, rank40 = {}, rank100 = {} }
	for run = 1, COUNT do
		local seed = (20261018 + 500 * 1000003 + run * 104729) % 2147483646 + 1
		for _ = 1, 3 do
			seed = D.uniform(seed)
		end
		local state = D.new(seed)
		local awards = D.advance(state, HORIZON, guaranteed)
		local values = {
			awards[1] or math.huge,
			if awards[2] then awards[2] - awards[1] else math.huge,
			awards[5] or math.huge,
			awards[15] or math.huge,
			awards[40] or math.huge,
			awards[100] or math.huge,
		}
		local row =
			{ tostring(run), tostring(seed), if guaranteed then "guaranteed" else "pure-control" }
		for i, id in { "first", "gap2", "rank5", "rank15", "rank40", "rank100" } do
			table.insert(metrics[id], values[i])
			table.insert(row, if values[i] < math.huge then tostring(values[i]) else "")
		end
		table.insert(records, table.concat(row, ","))
	end

	for _, metric in { "first", "gap2" } do
		local total = 0
		for _, value in metrics[metric] do
			total += value
		end
		local expected = if guaranteed then (1 - (1 - 0.00001) ^ 200000) / 0.00001 else 100000
		assert(math.abs(total / COUNT - expected) < 1500, "first/subsequent work mean mismatch")
		for _, threshold in { 50000, 100000, 199999, 200000 } do
			local count = 0
			for _, value in metrics[metric] do
				if value <= threshold then
					count += 1
				end
			end
			local expectedCdf = if guaranteed and threshold >= 200000
				then 1
				else 1 - (1 - 0.00001) ^ threshold
			assert(
				math.abs(count / COUNT - expectedCdf) < 0.005148,
				"first/subsequent work CDF mismatch"
			)
		end
	end
	for _, rate in { 1, 10, 30, 60 } do
		local summary = {}
		for _, id in { "first", "gap2", "rank5", "rank15", "rank40", "rank100" } do
			local times, censored = {}, 0
			for _, value in metrics[id] do
				table.insert(times, (value - (if id == "gap2" then 0 else 1)) / rate)
				if value == math.huge then
					censored += 1
				end
			end
			summary[id] = { seconds = M.quantiles(times, COUNT), censored = censored }
		end
		table.insert(output, {
			rate = rate,
			policy = if guaranteed then "guaranteed" else "pure-control",
			n = COUNT,
			horizonWork = HORIZON,
			metrics = summary,
		})
	end
	print(if guaranteed then "Guaranteed steady cohort done" else "Pure control steady cohort done")
end
fs.writeFile("build/balance/steady.csv", table.concat(records, "\n") .. "\n")
fs.writeFile("build/balance/steady.json", serde.encode("json", {
	modelVersion = "sustained-work-control-v1",
	masterSeed = 20261018,
	seedDerivation = "(master+500*1000003+run*104729)%2147483646+1; 3 Park-Miller advances",
	lune = process.exec("lune", { "--version" }).stdout:gsub("%s+$", ""),
	revision = process.exec("git", { "rev-parse", "HEAD" }).stdout:gsub("%s+$", ""),
	dirty = process.exec("git", { "status", "--porcelain" }).stdout ~= "",
	command = "lune run scripts/steadyBalance.luau",
	units = "documents, seconds online at constant rate; no absences; manual=online only at manual 1/s control",
	method = "100000 seeded work paths mapped at four sustained rates using common draws; first/ranks since first whole unit; gap2 subsequent first-to-second find; nearest rank and 99% DKW ideal-independent CDF band; missing observations censored as infinity",
	p = 0.00001,
	H = 200000,
	results = output,
}, true) .. "\n")
