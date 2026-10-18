--!strict
local Runner = require("../scripts/models/BalanceRunner")
local Scenarios = require("../scripts/balanceScenarios")
local function near(a: number, b: number)
	assert(math.abs(a - b) < 1e-6, tostring(a) .. " != " .. tostring(b))
end
local all = Scenarios.all()
local results = {}
for _, s in all do
	local r = Runner.run(s)
	results[s.id] = r
	near(r.totals.online, r.totals.simulated + r.totals.discarded)
	local again = Runner.run(s)
	near(r.totals.accepted, again.totals.accepted)
end
near(results["S1-starter"].totals.accepted, 600)
near(results["S1-starter"].totals.processed, 600 - 2 / 32)
near(results["S4-short-sessions"].totals.online, 900)
near(results["S4-short-sessions"].totals.accepted, results["S4-online-control"].totals.accepted)
near(results["S4-short-sessions"].totals.processed, results["S4-online-control"].totals.processed)
near(results["S6-cap"].totals.accepted, 216000)
local rows = results["S4-short-sessions"].rows
near(rows[2].totals.processed, rows[3].totals.processed)
near(rows[4].totals.accepted, rows[5].totals.accepted)
local invalid = Scenarios.all()[1]
invalid.sessions = { { start = 0, finish = 20 }, { start = 10, finish = 30 } }
assert(not pcall(Runner.run, invalid), "overlap accepted")
invalid = Scenarios.all()[1]
table.insert(
	invalid.events,
	{ id = "shrink", time = 5, line = "line1", patch = { outputCapacity = 1 } }
)
assert(not pcall(Runner.run, invalid), "destructive edit accepted")
invalid = Scenarios.all()[1]
invalid.h = 0 / 0
assert(not pcall(Runner.run, invalid), "NaN accepted")
local capped = Scenarios.all()[1]
capped.horizon = 1
capped.observations = { 0, 1 }
capped.sessions = { { start = 0, finish = 1 } }
capped.h = 1
capped.lines[1].config.maxStepSeconds = 0.25
local r = Runner.run(capped)
near(r.totals.simulated, 0.25)
near(r.totals.discarded, 0.75)
local combined = Scenarios.all()[1]
combined.horizon = 2
combined.sessions = { { start = 0, finish = 2 } }
combined.observations = { 0, 2 }
combined.lines[1].config.clearingRate = 40
combined.lines[1].config.outputCapacity = 100
for _, id in { "line2", "manual" } do
	table.insert(combined.lines, {
		id = id,
		state = { output = 0, processing = 0 },
		config = table.clone(combined.lines[1].config),
	})
end
near(Runner.run(combined).totals.accepted, 120)
for _, line in combined.lines do
	line.maximumExtractor = true
end
assert(not pcall(Runner.run, combined), "third maximum extractor accepted")
local boundary = Scenarios.all()[1]
boundary.horizon = 1
boundary.sessions = { { start = 0, finish = 1 } }
boundary.observations = { 0, 0.3, 1 }
boundary.h = 0.2
boundary.events = { { id = "stop", time = 0.3, line = "line1", patch = { clearingRate = 0 } } }
near(Runner.run(boundary).totals.accepted, 0.3)
print(
	"Balance runner: scenarios, sessions, boundaries, conservation, cap, invalid inputs and catch-up passed"
)
