--!strict
-- Experimental purchases and scripted voluntary promotion; NEVER runtime config.
local Production = require("./Production")
local Economy = {}

export type Scenario = {
	id: string,
	horizon: number,
	h: number,
	sessionSeconds: number,
	sessionPeriod: number,
	manualSeconds: number,
	decisionDelay: number,
	priceScale: number,
	capacity: number,
	stalls: { { start: number, finish: number, kind: string } },
	promote: boolean,
	promotionUnits: number,
	promotionFee: number,
	rebuildGrant: number,
	multiplier: number,
	fastForward: boolean?,
}

local function starter(capacity: number): any
	return {
		state = Production.empty(),
		config = {
			clearingRate = 1,
			transportRate = 1,
			processingRate = 1,
			outputCapacity = capacity,
			processingCapacity = capacity,
			maxStepSeconds = 2,
		},
	}
end

-- Ordered experiment strategy. Connection replacement is producer-approved;
-- all prices/delays/second-line bundle semantics remain explicit hypotheses.
local function policy(): { any }
	local purchases = {
		{ id = "extractor1", cost = 30, line = 1 },
		{ id = "processor1-basic", cost = 60, line = 1, field = "processingRate", value = 10 },
		{ id = "belt1-basic", cost = 5, line = 1, field = "transportRate", value = 10 },
		{ id = "extractor1-tier2", cost = 120, line = 1, field = "clearingRate", value = 10 },
		{ id = "processor1-tier2", cost = 350, line = 1, field = "processingRate", value = 40 },
		{ id = "belt1-upgrade", cost = 25, line = 1, field = "transportRate", value = 50 },
		{ id = "extractor1-tier3", cost = 600, line = 1, field = "clearingRate", value = 30 },
		{ id = "line2-connected", cost = 95, line = 2 },
		{ id = "extractor2-tier2", cost = 120, line = 2, field = "clearingRate", value = 10 },
		{ id = "processor2-tier2", cost = 350, line = 2, field = "processingRate", value = 40 },
		{ id = "belt2-upgrade", cost = 25, line = 2, field = "transportRate", value = 50 },
		{ id = "extractor2-tier3", cost = 600, line = 2, field = "clearingRate", value = 30 },
	}
	return purchases
end

local function finite(n: number)
	assert(type(n) == "number" and n == n and n >= 0 and n < math.huge, "invalid economy parameter")
end

function Economy.run(s: Scenario): any
	for _, key in
		{
			"horizon",
			"h",
			"sessionSeconds",
			"sessionPeriod",
			"manualSeconds",
			"decisionDelay",
			"priceScale",
			"capacity",
			"promotionUnits",
			"promotionFee",
			"rebuildGrant",
			"multiplier",
		}
	do
		finite((s :: any)[key])
	end
	assert(
		s.h > 0
			and s.h <= 2
			and s.horizon > 0
			and s.sessionSeconds > 0
			and s.sessionPeriod >= s.sessionSeconds,
		"invalid time configuration"
	)
	local previous = 0
	for _, stop in s.stalls do
		finite(stop.start)
		finite(stop.finish)
		assert(
			stop.start >= previous and stop.finish > stop.start and stop.finish <= s.horizon,
			"invalid stall"
		)
		assert(stop.kind == "transport" or stop.kind == "processing", "unknown stall kind")
		previous = stop.finish
	end
	local lines = { starter(s.capacity) }
	local purchases = policy()
	local purchaseIndex = 1
	local automatic = false
	local time, online, manual = 0, 0, 0
	local accepted, transported, processed, lost = 0, 0, 0, 0
	local intel, earned, spent = 0, 0, 0
	local grants, resetIntel = 0, 0
	local clearance = 0
	local nextDecision = 0
	local transactions, segments, snapshots = {}, {}, {}
	local constrained, deficit = 0, 0
	local areas = { output = 0, processing = 0, outputMax = 0, processingMax = 0, full = 0 }
	local firstPromotion: number? = nil
	local function inventory(): number
		local total = 0
		for _, line in lines do
			total += line.state.output + line.state.processing
		end
		return total
	end
	local function snapshot()
		table.insert(snapshots, {
			calendar = time,
			online = online,
			manual = manual,
			accepted = accepted,
			processed = processed,
			intel = intel,
			inventory = inventory(),
			lost = lost,
			clearance = clearance,
		})
	end
	snapshot()
	while time < s.horizon do
		local cycle = math.floor(time / s.sessionPeriod)
		local sessionStart = cycle * s.sessionPeriod
		local sessionEnd = math.min(s.horizon, sessionStart + s.sessionSeconds)
		if time >= sessionEnd then
			snapshot()
			time = math.min(s.horizon, (cycle + 1) * s.sessionPeriod)
			snapshot()
			continue
		end
		-- Decisions happen only online, after previous interval's ordinary income.
		if online >= nextDecision then
			local purchase = purchases[purchaseIndex]
			if purchase and intel + 1e-9 >= purchase.cost * s.priceScale then
				local cost = purchase.cost * s.priceScale
				intel -= cost
				spent += cost
				if purchase.id == "extractor1" then
					automatic = true
				end
				if purchase.id == "line2-connected" then
					local line = starter(s.capacity)
					line.config.transportRate = 10
					line.config.processingRate = 10
					table.insert(lines, line)
				elseif purchase.field then
					lines[purchase.line].config[purchase.field] = purchase.value
				end
				table.insert(transactions, {
					id = purchase.id,
					calendar = time,
					online = online,
					manual = manual,
					cost = cost,
					clearance = clearance,
					balance = intel,
					accepted = accepted,
				})
				purchaseIndex += 1
				nextDecision = online + s.decisionDelay
				snapshot()
			elseif
				s.promote
				and clearance == 0
				and purchase == nil
				and processed >= s.promotionUnits
				and intel >= s.promotionFee
			then
				-- Scenario explicitly scripts informed voluntary consent at this point.
				lost += inventory()
				spent += s.promotionFee
				resetIntel += intel - s.promotionFee
				intel = s.rebuildGrant
				grants += s.rebuildGrant
				clearance = 1
				firstPromotion = time
				table.insert(transactions, {
					id = "promotion-consent",
					calendar = time,
					online = online,
					manual = manual,
					cost = s.promotionFee,
					clearance = clearance,
					accepted = accepted,
					discardedInventory = inventory(),
				})
				lines = { starter(s.capacity) }
				automatic = false
				purchaseIndex = 1
				nextDecision = online + s.decisionDelay
				snapshot()
			end
		end
		local finish = math.min(sessionEnd, time + s.h)
		local manualEnd = sessionStart + s.manualSeconds
		if not automatic and manualEnd > time then
			finish = math.min(finish, manualEnd)
		end
		local blockedKind: string? = nil
		for _, stop in s.stalls do
			if stop.start > time then
				finish = math.min(finish, stop.start)
			end
			if time >= stop.start and time < stop.finish then
				blockedKind = stop.kind
				finish = math.min(finish, stop.finish)
			end
		end
		local dt = finish - time
		local manuallyActive = not automatic and time < manualEnd
		local beforeAccepted, beforeProcessed, beforeTransported = accepted, processed, transported
		local beforeInventory = inventory()
		local fixed = true
		local budget = 60 * dt
		local demandTotal = 0
		local outputBefore, processingBefore = 0, 0
		for _, line in lines do
			local config = table.clone(line.config)
			if not automatic and not manuallyActive then
				config.clearingRate = 0
			end
			if blockedKind == "transport" then
				config.transportRate = 0
			end
			if blockedKind == "processing" then
				config.processingRate = 0
			end
			demandTotal += config.clearingRate * dt
			config.clearingRate = math.min(config.clearingRate, budget / dt)
			local before = line.state
			outputBefore += before.output
			processingBefore += before.processing
			local r = Production.step(config, before, dt)
			assert(
				r.accepted <= config.clearingRate * r.simulatedSeconds + 1e-8,
				"clearing rate bound"
			)
			assert(
				r.transported <= config.transportRate * r.simulatedSeconds + 1e-8,
				"transport rate bound"
			)
			assert(
				r.processed <= config.processingRate * r.simulatedSeconds + 1e-8,
				"processing rate bound"
			)

			assert(
				math.abs(before.output + r.accepted - r.transported - r.state.output) < 1e-8,
				"output conservation"
			)
			assert(
				math.abs(before.processing + r.transported - r.processed - r.state.processing)
					< 1e-8,
				"processing conservation"
			)
			assert(r.discardedSeconds == 0, "unexpected discarded catch-up")
			fixed = fixed
				and math.abs(r.state.output - before.output) < 1e-12
				and math.abs(r.state.processing - before.processing) < 1e-12
			line.state = r.state
			budget -= r.accepted
			accepted += r.accepted
			transported += r.transported
			processed += r.processed
		end
		assert(budget >= -1e-8 and #lines <= 2, "global capacity")
		local a, p = accepted - beforeAccepted, processed - beforeProcessed
		-- At a verified fixed buffer state, the exact same discrete step repeats.
		-- Skip only whole h steps, with no remaining decision before a boundary.
		if
			s.fastForward ~= false
			and fixed
			and purchases[purchaseIndex] == nil
			and (not s.promote or clearance == 1)
			and dt == s.h
		then
			local boundary = sessionEnd
			for _, stop in s.stalls do
				if stop.start > time then
					boundary = math.min(boundary, stop.start)
				end
				if stop.finish > time then
					boundary = math.min(boundary, stop.finish)
				end
			end
			local extra = math.max(0, math.floor((boundary - finish) / s.h))
			accepted += extra * a
			transported += extra * (transported - beforeTransported)
			processed += extra * p
			demandTotal *= extra + 1
			dt *= extra + 1
			finish = time + dt
			a *= extra + 1
			p *= extra + 1
		end
		local income = p * (if clearance == 1 then s.multiplier else 1)
		intel += income
		earned += income
		deficit += demandTotal - a
		if a < demandTotal - 1e-9 then
			constrained += dt
		end
		areas.output += outputBefore * dt
		areas.processing += processingBefore * dt
		areas.outputMax = math.max(areas.outputMax, outputBefore)
		areas.processingMax = math.max(areas.processingMax, processingBefore)
		if beforeInventory >= #lines * 2 * s.capacity - 1e-9 then
			areas.full += dt
		end
		local previousSegment = segments[#segments]
		local rate = a / dt
		if
			previousSegment
			and previousSegment.finish == time
			and previousSegment.rate == rate
			and previousSegment.manualActive == manuallyActive
		then
			previousSegment.finish = finish
			previousSegment.acceptedFinish = accepted
		else
			table.insert(segments, {
				start = time,
				finish = finish,
				rate = rate,
				acceptedStart = beforeAccepted,
				acceptedFinish = accepted,
				onlineStart = online,
				manualStart = manual,
				manualActive = manuallyActive,
			})
		end
		online += dt
		if manuallyActive then
			manual += dt
		end
		time = finish
		assert(
			math.abs(accepted - processed - lost - inventory()) < 1e-6,
			"cumulative inventory conservation"
		)
		assert(
			math.abs(earned + grants - spent - resetIntel - intel) < 1e-6 and intel >= -1e-8,
			"currency conservation"
		)
	end
	snapshot()
	return {
		id = s.id,
		segments = segments,
		snapshots = snapshots,
		transactions = transactions,
		totals = {
			accepted = accepted,
			transported = transported,
			processed = processed,
			online = online,
			manual = manual,
			intel = intel,
			earned = earned,
			spent = spent,
			lost = lost,
			grants = grants,
			resetIntel = resetIntel,
			constrained = constrained,
			deficit = deficit,
		},
		metrics = areas,
		firstPromotion = firstPromotion,
		nextPurchase = purchases[purchaseIndex],
		clearance = clearance,
	}
end

return Economy
