--!strict
local Production = require("./models/Production")
local Runner = require("./models/BalanceRunner")
local Scenarios = {}

local function make(id: string, horizon: number, c: number, b: number, p: number): Runner.Scenario
	return {
		id = id,
		horizon = horizon,
		h = 1 / 32,
		sessions = { { start = 0, finish = horizon } },
		lines = {
			{
				id = "line1",
				state = Production.empty(),
				config = {
					clearingRate = c,
					transportRate = b,
					processingRate = p,
					outputCapacity = 5,
					processingCapacity = 3,
					maxStepSeconds = 2,
				},
			},
		},
		events = {},
		observations = { 0, horizon },
	}
end

local function progression(id: string): Runner.Scenario
	local s = make(id, 1200, 1, 10, 10)
	for _, e in
		{
			{ "extractor2", 120, "clearingRate", 10 },
			{ "extractor3", 300, "clearingRate", 30 },
			{ "processor2", 600, "processingRate", 40 },
			{ "belt2", 900, "transportRate", 50 },
		}
	do
		table.insert(
			s.events,
			{ id = e[1], time = e[2], line = "line1", patch = { [e[3]] = e[4] } } :: any
		)
	end
	s.observations = { 0, 120, 200, 260, 300, 400, 460, 600, 900, 1200 }
	return s
end

function Scenarios.all(): { Runner.Scenario }
	local s1 = make("S1-starter", 600, 1, 1, 1)
	local s2 = progression("S2-progression")
	local s3 = progression("S3-stalls")
	for _, e in
		{
			{ "transport-stop", 200, "transportRate", 0 },
			{ "transport-resume", 260, "transportRate", 10 },
			{ "processing-stop", 400, "processingRate", 0 },
			{ "processing-resume", 460, "processingRate", 10 },
		}
	do
		table.insert(
			s3.events,
			{ id = e[1], time = e[2], line = "line1", patch = { [e[3]] = e[4] } } :: any
		)
	end
	local s4 = make("S4-short-sessions", 86400, 1, 1, 1)
	s4.sessions = {
		{ start = 0, finish = 300 },
		{ start = 3600, finish = 3900 },
		{ start = 82800, finish = 83100 },
	}
	s4.observations = { 0, 300, 3600, 3900, 82800, 83100, 86400 }
	local all = { s1, s2, s3, s4, make("S4-online-control", 900, 1, 1, 1) }
	for _, capacity in { { 1, 1 }, { 5, 3 }, { 50, 30 } } do
		for _, h in { 1 / 32, 1 / 64 } do
			local s = progression("S5-" .. capacity[1] .. "-" .. capacity[2] .. "-h" .. tostring(h))
			s.h = h
			s.lines[1].config.outputCapacity = capacity[1]
			s.lines[1].config.processingCapacity = capacity[2]
			table.insert(all, s)
		end
	end
	local s6 = make("S6-cap", 3600, 30, 50, 40)
	s6.lines[1].maximumExtractor = true
	s6.lines[1].config.outputCapacity = 50
	s6.lines[1].config.processingCapacity = 30
	table.insert(s6.lines, {
		id = "line2",
		maximumExtractor = true,
		state = Production.empty(),
		config = table.clone(s6.lines[1].config),
	})
	s6.observations = { 0, 1, 60, 3600 }
	table.insert(all, s6)
	return all
end

return Scenarios
