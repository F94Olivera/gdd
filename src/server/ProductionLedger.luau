--!strict
-- Server-authoritative accepted-unit accounting and shared clearing budget (M1-02).
-- Pure: no Roblox services, clock, RNG or persistence. The caller owns elapsed time
-- and line configuration; this module never trusts client input directly.
-- Each line step repeats the verified M0 two-buffer formula
-- (scripts/models/Production.luau); tests/productionLedger.luau keeps them identical.

export type Limits = {
	-- D-012 shared cap for manual + automatic clearing across every line.
	maxEligiblePerSecond: number,
	maxMaximumLines: number,
	-- Clearing rate that counts as a maximum-capacity line.
	maximumLineRate: number,
	tickSeconds: number,
	maxCatchUpSeconds: number,
	-- D-017: accepted work not yet confirmed durable; clearing stops at this bound.
	maxProvisionalUnits: number,
}

export type LineConfig = {
	id: string,
	clearingRate: number,
	transportRate: number,
	processingRate: number,
	outputCapacity: number,
	processingCapacity: number,
}

export type LineState = {
	output: number,
	processing: number,
}

export type State = {
	lines: { [string]: LineState },
	-- Continuous cumulative accepted work, including the pending fraction.
	accepted: number,
	-- Highest whole eligible unit ID handed out; IDs start at 1.
	assignedUnits: number,
	-- Highest unit ID confirmed durable by the persistence layer.
	confirmedUnits: number,
	processed: number,
}

-- Inclusive range of new whole unit IDs accepted by one line.
export type UnitRange = {
	line: string,
	first: number,
	last: number,
}

export type Result = {
	state: State,
	accepted: number,
	transported: number,
	processed: number,
	units: { UnitRange },
	steps: number,
	simulatedSeconds: number,
	discardedSeconds: number,
	-- Some line wanted to clear more than the shared cap allowed.
	budgetLimited: boolean,
	-- Clearing stopped because provisional work reached its bound.
	provisionalLimited: boolean,
}

local Ledger = {}

-- Matches the BalanceMetrics tolerance: snaps float noise, never adds credit.
local WHOLE_EPSILON = 1e-8

local function finite(value: any, name: string)
	assert(
		type(value) == "number" and value == value and value >= 0 and value < math.huge,
		name .. " must be finite and nonnegative"
	)
end

local function whole(accepted: number): number
	return math.floor(accepted + WHOLE_EPSILON)
end

function Ledger.new(confirmedUnits: number?): State
	local start = confirmedUnits or 0
	finite(start, "confirmedUnits")
	assert(start % 1 == 0, "confirmedUnits must be whole")
	return {
		lines = {},
		accepted = start,
		assignedUnits = start,
		confirmedUnits = start,
		processed = 0,
	}
end

local function validateLimits(limits: Limits)
	for _, field in
		{
			"maxEligiblePerSecond",
			"maxMaximumLines",
			"maximumLineRate",
			"tickSeconds",
			"maxCatchUpSeconds",
			"maxProvisionalUnits",
		}
	do
		finite((limits :: any)[field], field)
	end
	assert(limits.tickSeconds > 0, "tickSeconds must be positive")
	assert(limits.maximumLineRate > 0, "maximumLineRate must be positive")
end

-- Returns lines sorted by ID: the stable priority for the shared budget.
local function validateLines(limits: Limits, lines: { LineConfig }, state: State): { LineConfig }
	local sorted = table.clone(lines)
	local seen = {}
	local maximumLines = 0
	for _, line in sorted do
		assert(type(line.id) == "string" and line.id ~= "", "line id must be a non-empty string")
		assert(not seen[line.id], "duplicate line id " .. line.id)
		seen[line.id] = true
		finite(line.clearingRate, "clearingRate")
		finite(line.transportRate, "transportRate")
		finite(line.processingRate, "processingRate")
		finite(line.outputCapacity, "outputCapacity")
		finite(line.processingCapacity, "processingCapacity")
		if line.clearingRate >= limits.maximumLineRate then
			maximumLines += 1
		end
		local current = state.lines[line.id]
		if current then
			finite(current.output, "output")
			finite(current.processing, "processing")
			assert(current.output <= line.outputCapacity, "output exceeds capacity")
			assert(current.processing <= line.processingCapacity, "processing exceeds capacity")
		end
	end
	assert(maximumLines <= limits.maxMaximumLines, "too many maximum-capacity lines")
	for id in state.lines do
		assert(seen[id], "state holds inventory for unknown line " .. id)
	end
	table.sort(sorted, function(a, b)
		return a.id < b.id
	end)
	return sorted
end

-- Same arithmetic as the M0 Production.step for one bounded step of dt seconds.
-- clearingLimit is the line's share of the remaining shared budget for this step.
local function stepLine(line: LineConfig, state: LineState, dt: number, clearingLimit: number)
	local processed = math.min(state.processing, line.processingRate * dt)
	local processing = state.processing - processed
	local transported =
		math.min(state.output, line.transportRate * dt, line.processingCapacity - processing)
	processing += transported
	local output = state.output - transported
	local accepted = math.min(line.clearingRate * dt, clearingLimit, line.outputCapacity - output)
	output += accepted
	return { output = output, processing = processing }, accepted, transported, processed
end

-- Advances every line by elapsedSeconds of online time. Time beyond
-- maxCatchUpSeconds is discarded, never banked; unused budget expires each step.
-- Inputs are not mutated.
function Ledger.advance(
	limits: Limits,
	lines: { LineConfig },
	state: State,
	elapsedSeconds: number
): Result
	validateLimits(limits)
	finite(elapsedSeconds, "elapsedSeconds")
	finite(state.accepted, "accepted")
	finite(state.processed, "processed")
	assert(state.assignedUnits == whole(state.accepted), "assignedUnits out of sync with accepted")
	assert(state.confirmedUnits <= state.assignedUnits, "confirmedUnits ahead of assignedUnits")
	local sorted = validateLines(limits, lines, state)

	local lineStates: { [string]: LineState } = {}
	for _, line in sorted do
		local current = state.lines[line.id]
		lineStates[line.id] = if current
			then { output = current.output, processing = current.processing }
			else { output = 0, processing = 0 }
	end

	local accepted = state.accepted
	local totals = { accepted = 0, transported = 0, processed = 0 }
	local units: { UnitRange } = {}
	local budgetLimited, provisionalLimited = false, false
	local simulated = math.min(elapsedSeconds, limits.maxCatchUpSeconds)
	-- Whole ticks plus one shorter remainder step; counting ticks avoids float drift
	-- adding a spurious near-zero step.
	local fullTicks = math.floor(simulated / limits.tickSeconds + 1e-9)
	local remainder = simulated - fullTicks * limits.tickSeconds
	local steps = fullTicks + (if remainder > 1e-9 then 1 else 0)
	for step = 1, steps do
		local dt = if step <= fullTicks then limits.tickSeconds else remainder
		local budget = limits.maxEligiblePerSecond * dt
		local provisionalRoom =
			math.max(0, limits.maxProvisionalUnits - (accepted - state.confirmedUnits))
		for _, line in sorted do
			local demand = line.clearingRate * dt
			local limit = math.min(budget, provisionalRoom)
			local before = whole(accepted)
			local nextState, lineAccepted, transported, processed =
				stepLine(line, lineStates[line.id], dt, limit)
			lineStates[line.id] = nextState
			-- Flag only when the shared limit, not a full buffer, was the binding bound.
			if limit < demand - 1e-12 and lineAccepted >= limit - 1e-12 then
				if budget <= provisionalRoom then
					budgetLimited = true
				else
					provisionalLimited = true
				end
			end
			budget -= lineAccepted
			provisionalRoom -= lineAccepted
			accepted += lineAccepted
			totals.accepted += lineAccepted
			totals.transported += transported
			totals.processed += processed
			local after = whole(accepted)
			if after > before then
				local last = units[#units]
				if last and last.line == line.id and last.last == before then
					last.last = after
				else
					table.insert(units, { line = line.id, first = before + 1, last = after })
				end
			end
		end
	end

	return {
		state = {
			lines = lineStates,
			accepted = accepted,
			assignedUnits = whole(accepted),
			confirmedUnits = state.confirmedUnits,
			processed = state.processed + totals.processed,
		},
		accepted = totals.accepted,
		transported = totals.transported,
		processed = totals.processed,
		units = units,
		steps = steps,
		simulatedSeconds = simulated,
		discardedSeconds = elapsedSeconds - simulated,
		budgetLimited = budgetLimited,
		provisionalLimited = provisionalLimited,
	}
end

-- Records that every unit up to throughUnit is durable. Only whole, already
-- assigned units can be confirmed, and the cursor never moves backwards.
function Ledger.confirm(state: State, throughUnit: number): State
	finite(throughUnit, "throughUnit")
	assert(throughUnit % 1 == 0, "throughUnit must be whole")
	assert(throughUnit >= state.confirmedUnits, "confirmed cursor cannot move backwards")
	assert(throughUnit <= state.assignedUnits, "cannot confirm units that were not accepted")
	local lines = {}
	for id, line in state.lines do
		lines[id] = { output = line.output, processing = line.processing }
	end
	return {
		lines = lines,
		accepted = state.accepted,
		assignedUnits = state.assignedUnits,
		confirmedUnits = throughUnit,
		processed = state.processed,
	}
end

return table.freeze(Ledger)
