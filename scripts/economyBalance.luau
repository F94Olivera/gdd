--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local E = require("./models/EconomyExperiment")
local D = require("./models/DiscoveryExperiment")
local M = require("./models/BalanceMetrics")
local Scenarios = require("./economyScenarios")
local COUNT = 100000
local MASTER = 20261018
local ranks = { 1, 5, 15, 40, 100 }
local selectedScenario = process.args[1]
local selectedRun = if process.args[2] then tonumber(process.args[2]) else nil
assert(not process.args[2] or selectedRun ~= nil, "invalid run index")
assert(
	not selectedRun or (selectedRun >= 1 and selectedRun <= COUNT and selectedRun % 1 == 0),
	"invalid run index"
)
local summaries, trajectories = {}, {}
fs.writeDir("build/balance/economy")
for scenarioIndex, s in Scenarios.all() do
	if selectedScenario and selectedScenario ~= s.id then
		continue
	end
	local result = E.run(s)
	table.insert(trajectories, { scenario = s, result = result })
	local whole = M.whole(result.totals.accepted)
	local originCalendar, originOnline, originManual = 0, 0, 0
	if whole > 0 then
		originCalendar, originOnline, originManual = M.timeAt(result.segments, 1)
	end
	local records = {
		"run,seed,policy,archives,failures,first_calendar,first_online,first_manual,gap2_calendar,gap2_online,gap2_manual,rank5_calendar,rank15_calendar,rank40_calendar,rank100_calendar",
	}
	for _, guaranteed in { true, false } do
		local observations = {}
		for _, id in { "first", "gap2", "rank5", "rank15", "rank40", "rank100" } do
			observations[id] = { calendar = {}, online = {}, manual = {}, censored = 0 }
		end
		local firstRun = selectedRun or 1
		local lastRun = selectedRun or COUNT
		for run = firstRun, lastRun do
			local seed = (MASTER + (scenarioIndex + 200) * 1000003 + run * 104729) % 2147483646 + 1
			for _ = 1, 3 do
				seed = D.uniform(seed)
			end
			local state = D.new(seed)
			local awards = D.advance(state, whole, guaranteed)
			local firstTimes = nil
			local row = {
				tostring(run),
				tostring(seed),
				if guaranteed then "guaranteed" else "pure-control",
				tostring(state.archives),
				tostring(state.failures),
			}
			for _, rank in ranks do
				local id = if rank == 1 then "first" else "rank" .. rank
				local obs = observations[id]
				local times = { math.huge, math.huge, math.huge }
				if awards[rank] then
					local c, o, m = M.timeAt(result.segments, awards[rank])
					times = { c - originCalendar, o - originOnline, m - originManual }
				else
					obs.censored += 1
				end
				table.insert(obs.calendar, times[1])
				table.insert(obs.online, times[2])
				table.insert(obs.manual, times[3])
				if rank == 1 then
					firstTimes = times
					for _, t in times do
						table.insert(row, if t < math.huge then string.format("%.9f", t) else "")
					end
					local gap = { math.huge, math.huge, math.huge }
					if awards[2] then
						local c, o, m = M.timeAt(result.segments, awards[2])
						gap = {
							c - originCalendar - times[1],
							o - originOnline - times[2],
							m - originManual - times[3],
						}
					else
						observations.gap2.censored += 1
					end
					for i, dimension in { "calendar", "online", "manual" } do
						table.insert(observations.gap2[dimension], gap[i])
						table.insert(
							row,
							if gap[i] < math.huge then string.format("%.9f", gap[i]) else ""
						)
					end
				else
					table.insert(
						row,
						if times[1] < math.huge then string.format("%.9f", times[1]) else ""
					)
				end
			end
			assert(firstTimes ~= nil)
			table.insert(records, table.concat(row, ","))
		end
		local output = {}
		for _, id in { "first", "gap2", "rank5", "rank15", "rank40", "rank100" } do
			local obs = observations[id]
			output[id] = {
				censored = obs.censored,
				calendar = M.quantiles(obs.calendar, lastRun - firstRun + 1),
				online = M.quantiles(obs.online, lastRun - firstRun + 1),
				manual = M.quantiles(obs.manual, lastRun - firstRun + 1),
			}
		end
		table.insert(summaries, {
			scenario = s.id,
			policy = if guaranteed then "guaranteed" else "pure-control",
			n = lastRun - firstRun + 1,
			metrics = output,
		})
	end
	fs.writeFile(
		"build/balance/economy/"
			.. s.id
			.. (if selectedRun then "-run" .. selectedRun else "")
			.. ".csv",
		table.concat(records, "\n") .. "\n"
	)
	print(
		s.id,
		"A",
		result.totals.accepted,
		"online",
		result.totals.online,
		"manual",
		result.totals.manual,
		"promotion",
		result.firstPromotion
	)
end
assert(#trajectories > 0, "unknown scenario")
local function git(args: { string }): string
	local r = process.exec("git", args)
	assert(r.ok, "git provenance failed")
	return r.stdout:gsub("%s+$", "")
end
local sources = {}
for _, path in
	{
		"scripts/models/Production.luau",
		"scripts/models/EconomyExperiment.luau",
		"scripts/models/DiscoveryExperiment.luau",
		"scripts/models/BalanceMetrics.luau",
		"scripts/economyScenarios.luau",
		"scripts/economyBalance.luau",
	}
do
	sources[path] = git({ "hash-object", path })
end
local artifact = {
	schemaVersion = 1,
	modelVersion = "economy-natural-stream-v1",
	balanceVersion = "D011-D016-experiments-v2",
	revision = git({ "rev-parse", "HEAD" }),
	dirty = git({ "status", "--porcelain" }) ~= "",
	sourceHashes = sources,
	lune = process.exec("lune", { "--version" }).stdout:gsub("%s+$", ""),
	masterSeed = MASTER,
	n = if selectedRun then 1 else COUNT,
	command = "lune run scripts/economyBalance.luau" .. (if selectedScenario
		then " " .. selectedScenario
		else "") .. (if selectedRun then " " .. selectedRun else ""),
	seedDerivation = "(20261018+(scenarioIndex+200)*1000003+run*104729)%2147483646+1; three Park-Miller advances; scenario order in economyScenarios.all",
	p = 0.00001,
	H = 200000,
	cap = 60,
	ranks = ranks,
	trajectories = trajectories,
	summaries = summaries,
	method = "nearest-rank over whole cohort, censor as infinity; 99% DKW band conditional on ideal independent draws; fixed policy independent of RNG; E10 prices/first promotion and rank thresholds approved D014-D016; buffers/sessions/delays/connection bundle hypotheses; other economy candidates experimental; first and ranks since first whole unit; gap2 from first award (censored if <2); times interpolate accepted-rate step; manual is active manual clearing time, excludes automation; source hashes identify dirty model exactly",
}
fs.writeFile(
	"build/balance/economy/"
		.. (if selectedScenario then selectedScenario else "all")
		.. (if selectedRun then "-run" .. selectedRun else "")
		.. ".json",
	serde.encode("json", artifact, true) .. "\n"
)
