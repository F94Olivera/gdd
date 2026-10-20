--!strict
local Economy = require("./models/EconomyExperiment")
local Scenarios = {}

function Scenarios.base(): Economy.Scenario
	return {
		id = "E1-baseline",
		horizon = 360000,
		h = 1 / 32,
		sessionSeconds = 360000,
		sessionPeriod = 360000,
		manualSeconds = 360000,
		decisionDelay = 5,
		priceScale = 1,
		capacity = 50,
		stalls = {},
		promote = false,
		-- Approved first promotion (D-014). E6/E12 opt into the rejected 25k/10k alternative.
		promotionUnits = 100000,
		promotionFee = 50000,
		rebuildGrant = 100,
		multiplier = 1.25,
	}
end

function Scenarios.all(): { Economy.Scenario }
	local all = { Scenarios.base() }
	local short = Scenarios.base()
	short.id = "E2-five-min-hourly"
	short.sessionSeconds = 300
	short.sessionPeriod = 3600
	table.insert(all, short)
	local daily = Scenarios.base()
	daily.id = "E3-thirty-min-daily"
	daily.horizon = 100 * 86400
	daily.sessionSeconds = 1800
	daily.sessionPeriod = 86400
	table.insert(all, daily)
	local blocked = Scenarios.base()
	blocked.id = "E4-block-reconnect"
	blocked.sessionSeconds = 600
	blocked.sessionPeriod = 900
	blocked.stalls = {
		{ start = 120, finish = 180, kind = "transport" },
		{ start = 400, finish = 500, kind = "processing" },
	}
	table.insert(all, blocked)
	local expensive = Scenarios.base()
	expensive.id = "E5-prices-x5"
	expensive.priceScale = 5
	table.insert(all, expensive)
	local promotion = Scenarios.base()
	promotion.id = "E6-promotion"
	promotion.promote = true
	promotion.promotionUnits = 25000
	promotion.promotionFee = 10000
	table.insert(all, promotion)
	local limited = Scenarios.base()
	limited.id = "E7-manual-10s-daily"
	limited.horizon = 30 * 86400
	limited.sessionSeconds = 300
	limited.sessionPeriod = 86400
	limited.manualSeconds = 10
	table.insert(all, limited)
	local small = Scenarios.base()
	small.id = "E8-small-buffer"
	small.capacity = 1
	table.insert(all, small)
	local doubled = Scenarios.base()
	doubled.id = "E9-prices-x2"
	doubled.priceScale = 2
	table.insert(all, doubled)
	local later = Scenarios.base()
	later.id = "E10-later-promotion"
	later.promote = true
	table.insert(all, later)

	local insufficient = Scenarios.base()
	insufficient.id = "E11-insufficient-manual"
	insufficient.horizon = 600
	insufficient.sessionSeconds = 300
	insufficient.sessionPeriod = 3600
	insufficient.manualSeconds = 10
	table.insert(all, insufficient)

	local doubledEarly = Scenarios.base()
	doubledEarly.id = "E12-prices-x2-early-promotion"
	doubledEarly.priceScale = 2
	doubledEarly.promote = true
	doubledEarly.promotionUnits = 25000
	doubledEarly.promotionFee = 10000
	table.insert(all, doubledEarly)
	local doubledLate = Scenarios.base()
	doubledLate.id = "E13-prices-x2-later-promotion"
	doubledLate.priceScale = 2
	doubledLate.promote = true
	table.insert(all, doubledLate)

	return all
end

return Scenarios
