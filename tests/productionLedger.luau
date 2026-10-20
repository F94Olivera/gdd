--!strict
-- M1-02: accepted-unit accounting, shared clearing budget and provisional bound.
local Ledger = require("../src/server/ProductionLedger")
local Catalog = require("../src/shared/Catalog")
local Production = require("../scripts/models/Production")
local defs = Catalog.definitions
local limits = Catalog.productionLimits(defs)
local BUFFER = defs.simulation.lineBufferUnits

local function near(a: number, b: number, tolerance: number?)
	assert(math.abs(a - b) <= (tolerance or 1e-8), tostring(a) .. " != " .. tostring(b))
end

local function line(
	id: string,
	clearing: number,
	transport: number,
	processing: number
): Ledger.LineConfig
	return {
		id = id,
		clearingRate = clearing,
		transportRate = transport,
		processingRate = processing,
		outputCapacity = BUFFER,
		processingCapacity = BUFFER,
	}
end

local function inventory(state: Ledger.State): number
	local total = 0
	for _, l in state.lines do
		total += l.output + l.processing
	end
	return total
end

-- Runs updates of the given lengths, checking invariants after every update.
-- Each update is confirmed right away, standing in for the durable checkpoint;
-- pass holdProvisional to leave the work unconfirmed.
local function run(
	lines: { Ledger.LineConfig },
	updates: { number },
	start: Ledger.State?,
	holdProvisional: boolean?
)
	local useLimits = limits
	local state = start or Ledger.new()
	local nextUnit = state.assignedUnits + 1
	local initial = state.accepted - inventory(state) - state.processed
	for _, elapsed in updates do
		local r = Ledger.advance(useLimits, lines, state, elapsed)
		near(r.simulatedSeconds, math.min(elapsed, useLimits.maxCatchUpSeconds))
		near(r.discardedSeconds, elapsed - r.simulatedSeconds)
		-- D-012: never more than the shared cap, even across a catch-up update.
		assert(
			r.accepted <= useLimits.maxEligiblePerSecond * r.simulatedSeconds + 1e-8,
			"cap exceeded"
		)
		-- Unit IDs are contiguous, never repeated and match floor(accepted).
		for _, range in r.units do
			assert(range.first == nextUnit and range.last >= range.first, "unit gap or repeat")
			nextUnit = range.last + 1
		end
		assert(r.state.assignedUnits == nextUnit - 1)
		assert(r.state.assignedUnits == math.floor(r.state.accepted + 1e-8))
		-- Conservation: accepted = in buffers + processed.
		near(r.state.accepted - inventory(r.state) - r.state.processed, initial, 1e-6)
		for _, l in lines do
			local s = r.state.lines[l.id]
			assert(s.output >= 0 and s.output <= l.outputCapacity + 1e-9)
			assert(s.processing >= 0 and s.processing <= l.processingCapacity + 1e-9)
		end
		state = if holdProvisional then r.state else Ledger.confirm(r.state, r.state.assignedUnits)
	end
	return state
end

local function repeated(value: number, count: number): { number }
	local out = table.create(count, value)
	return out
end

-- 1. The runtime line step is the verified M0 formula: identical results.
do
	local seed = 12345
	local function rand(): number
		seed = (seed * 16807) % 2147483647
		return seed / 2147483647
	end
	for _ = 1, 2000 do
		local cfg = line("a", rand() * 40, rand() * 60, rand() * 50)
		cfg.outputCapacity = 1 + rand() * 60
		cfg.processingCapacity = 1 + rand() * 60
		local s =
			{ output = rand() * cfg.outputCapacity, processing = rand() * cfg.processingCapacity }
		local dt = rand() * 0.2
		local state = Ledger.new()
		state.lines = { a = s }
		local open = table.clone(limits)
		open.maxEligiblePerSecond = 1e6
		open.maxProvisionalUnits = 1e9
		open.maximumLineRate = 1e6
		local r = Ledger.advance(open, { cfg }, state, dt)
		local m = Production.step({
			clearingRate = cfg.clearingRate,
			transportRate = cfg.transportRate,
			processingRate = cfg.processingRate,
			outputCapacity = cfg.outputCapacity,
			processingCapacity = cfg.processingCapacity,
			maxStepSeconds = 0.2,
		}, s, dt)
		assert(
			r.accepted == m.accepted
				and r.transported == m.transported
				and r.processed == m.processed
		)
		assert(
			r.state.lines.a.output == m.state.output
				and r.state.lines.a.processing == m.state.processing
		)
	end
end

-- 2. Two D-012 reference lines (30 clear / 50 belt / 40 process) at 5 Hz with the
-- experimental 50-unit buffers sustain exactly 60/s once started.
do
	local lines = { line("line_a", 30, 50, 40), line("line_b", 30, 50, 40) }
	local warm = run(lines, repeated(0.2, 10))
	local after = run(lines, repeated(0.2, 300), warm)
	near(after.accepted - warm.accepted, 60 * 60, 1e-6)
	near(after.processed - warm.processed, 60 * 60, 1e-6)
	-- Two-second catch-up updates keep the same throughput (sub-stepped at 0.2 s).
	local caught = run(lines, repeated(2, 30), warm)
	near(caught.accepted - warm.accepted, 60 * 60, 1e-6)
	near(caught.processed - warm.processed, 60 * 60, 1e-6)
end

-- 3. Uneven server frame times give the same sustained flow as fixed ticks.
do
	local lines = { line("line_a", 30, 50, 40) }
	local frames = {}
	local total = 0
	local pattern = { 0.016, 0.033, 0.25, 0.07, 0.2, 0.41, 0.005 }
	while total < 120 do
		local f = pattern[#frames % #pattern + 1]
		table.insert(frames, f)
		total += f
	end
	local variable = run(lines, frames)
	local fixed = run(lines, repeated(0.2, math.floor(total / 0.2)))
	-- Startup latency is at most two ticks of 30/s; afterwards both run at 30/s.
	near(variable.accepted, 30 * total, 1e-6)
	near(fixed.accepted, 30 * math.floor(total / 0.2) * 0.2, 1e-6)
	assert(variable.processed >= 30 * total - 2 * 0.41 * 30 - 1e-6)
end

-- 4. Shared budget: stable ID priority and no third maximum line.
do
	local lines =
		{ line("c_small", 10, 50, 40), line("a_max", 30, 50, 40), line("b_max", 30, 50, 40) }
	local r = Ledger.advance(limits, lines, Ledger.new(), 0.2)
	near(r.accepted, 12)
	assert(r.budgetLimited and not r.provisionalLimited)
	near(r.state.lines.a_max.output, 6)
	near(r.state.lines.b_max.output, 6)
	near(r.state.lines.c_small.output, 0)
	assert(r.units[1].line == "a_max" and r.units[#r.units].line == "b_max")
	local third = { line("a", 30, 50, 40), line("b", 30, 50, 40), line("c", 30, 50, 40) }
	assert(
		not pcall(Ledger.advance, limits, third, Ledger.new(), 0.2),
		"third maximum line accepted"
	)
	-- Manual clearing on the starter lane shares the same cap (D-012).
	local manual =
		{ line("starter_lane", 1, 1, 1), line("x_max", 30, 50, 40), line("y_max", 30, 50, 40) }
	local m = run(manual, repeated(0.2, 50))
	near(m.accepted, 60 * 10, 1e-6)
end

-- 5. No banking: a stalled belt fills the buffer, clearing stops, and recovery
-- never exceeds the line rate or the shared cap.
do
	local stalled = { line("line_a", 30, 0, 40) }
	local full = run(stalled, repeated(0.2, 50))
	near(full.lines.line_a.output, BUFFER)
	near(full.accepted, BUFFER)
	local still = Ledger.advance(limits, stalled, full, 0.2)
	near(still.accepted, 0)
	assert(not still.budgetLimited and not still.provisionalLimited)
	local resumed = { line("line_a", 30, 50, 40) }
	local before = full.accepted
	local after = run(resumed, repeated(0.2, 5), full)
	assert(after.accepted - before <= 30 * 1 + 1e-8, "blocked time was banked")
end

-- 6. Fractions survive updates: a 0.3/s lane yields its 3rd whole unit at 10 s.
do
	local slow = { line("starter_lane", 0.3, 1, 1) }
	local state = Ledger.new()
	local found = {}
	for tick = 1, 50 do
		local r = Ledger.advance(limits, slow, state, 0.2)
		for _, range in r.units do
			for id = range.first, range.last do
				found[id] = tick
			end
		end
		state = r.state
	end
	assert(found[1] == 17 and found[2] == 34 and found[3] == 50 and found[4] == nil)
	near(state.accepted, 3)
end

-- 7. Provisional bound (D-017): clearing stops at 600 unconfirmed units, resumes
-- after confirmation, and the confirmed cursor only moves forward over assigned IDs.
do
	local lines = { line("line_a", 30, 50, 40), line("line_b", 30, 50, 40) }
	local state = run(lines, repeated(0.2, 60), nil, true)
	near(state.accepted, 600)
	local blocked = Ledger.advance(limits, lines, state, 0.2)
	near(blocked.accepted, 0)
	assert(blocked.provisionalLimited)
	local confirmed = Ledger.confirm(blocked.state, 300)
	assert(confirmed.confirmedUnits == 300 and blocked.state.confirmedUnits == 0)
	local resumed = Ledger.advance(limits, lines, confirmed, 0.2)
	near(resumed.accepted, 12)
	assert(not pcall(Ledger.confirm, confirmed, 299), "cursor moved backwards")
	assert(not pcall(Ledger.confirm, confirmed, 601), "confirmed unaccepted units")
	assert(not pcall(Ledger.confirm, confirmed, 300.5), "confirmed a fraction")
	-- A loaded profile resumes IDs after its durable cursor.
	local loaded = Ledger.new(1234)
	local r = Ledger.advance(limits, { line("line_a", 30, 50, 40) }, loaded, 0.2)
	assert(r.units[1].first == 1235 and r.units[1].last == 1240)
end

-- 8. Inputs are not mutated and invalid inputs are rejected.
do
	local lines = { line("line_a", 30, 50, 40) }
	local state = run(lines, repeated(0.2, 3))
	local snapshot = { accepted = state.accepted, output = state.lines.line_a.output }
	Ledger.advance(limits, lines, state, 0.2)
	assert(state.accepted == snapshot.accepted and state.lines.line_a.output == snapshot.output)
	assert(lines[1].clearingRate == 30)
	local bad: { () -> () } = {
		function()
			Ledger.advance(limits, lines, state, 0 / 0)
		end,
		function()
			Ledger.advance(limits, lines, state, -1)
		end,
		function()
			Ledger.advance(limits, lines, state, math.huge)
		end,
		function()
			Ledger.advance(limits, { line("line_a", -1, 50, 40) }, state, 0.2)
		end,
		function()
			Ledger.advance(
				limits,
				{ line("line_a", 30, 50, 40), line("line_a", 1, 1, 1) },
				state,
				0.2
			)
		end,
		function()
			Ledger.advance(limits, { line("other", 30, 50, 40) }, state, 0.2)
		end,
		function()
			local tight = line("line_a", 30, 50, 40)
			tight.outputCapacity = 0.5
			Ledger.advance(limits, { tight }, state, 0.2)
		end,
		function()
			local broken = table.clone(limits)
			broken.tickSeconds = 0
			Ledger.advance(broken, lines, Ledger.new(), 0.2)
		end,
		function()
			local drifted = table.clone(state)
			drifted.assignedUnits += 1
			Ledger.advance(limits, lines, drifted, 0.2)
		end,
		function()
			Ledger.new(-1)
		end,
	}
	for index, attempt in bad do
		assert(not pcall(attempt), "invalid input " .. index .. " accepted")
	end
end

print(
	"Production ledger: M0 formula parity, 60/s reference, catch-up, variable frames, budget priority, no banking, fractions, provisional bound and invalid inputs passed"
)
