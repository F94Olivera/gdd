--!strict
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local E = require("./models/EconomyExperiment")
local S = require("./economyScenarios")
local Runner = require("./models/BalanceRunner")
local ProductionScenarios = require("./balanceScenarios")
local report = { economy = {}, production = {} }
for _, scenario in S.all() do
	local fine = table.clone(scenario)
	fine.h = scenario.h / 2
	local coarseResult, fineResult = E.run(scenario), E.run(fine)
	local purchases = {}
	assert(#coarseResult.transactions == #fineResult.transactions, "purchase count sensitive to h")
	for i, a in coarseResult.transactions do
		local b = fineResult.transactions[i]
		assert(a.id == b.id and a.clearance == b.clearance, "purchase order sensitive to h")
		table.insert(purchases, {
			id = a.id,
			clearance = a.clearance,
			calendarDifference = b.calendar - a.calendar,
			onlineDifference = b.online - a.online,
		})
	end
	local delta = fineResult.totals.accepted - coarseResult.totals.accepted
	assert(math.abs(delta) < 100, "unexplained economic sensitivity >100 work units")
	table.insert(report.economy, {
		id = scenario.id,
		coarse = scenario.h,
		fine = fine.h,
		acceptedDifference = delta,
		processedDifference = fineResult.totals.processed - coarseResult.totals.processed,
		purchases = purchases,
	})
	print(scenario.id, "delta A", delta)
end
local all = ProductionScenarios.all()
for index = 6, 11, 2 do
	local coarse, fine = Runner.run(all[index]), Runner.run(all[index + 1])
	local windows = {}
	for i = 2, #coarse.rows do
		local a0, a1 = coarse.rows[i - 1], coarse.rows[i]
		local b0, b1 = fine.rows[i - 1], fine.rows[i]
		local differences = {}
		for _, field in { "accepted", "transported", "processed" } do
			differences[field] = (b1.totals[field] - b0.totals[field])
				- (a1.totals[field] - a0.totals[field])
		end
		table.insert(windows, { start = a0.time, finish = a1.time, delta = differences })
	end
	table.insert(report.production, { id = coarse.id, windows = windows })
end
fs.writeDir("build/balance")
fs.writeFile("build/balance/sensitivity.json", serde.encode("json", report, true) .. "\n")
