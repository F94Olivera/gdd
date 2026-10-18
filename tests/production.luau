--!strict
local Production = require("../scripts/models/Production")

-- Arbitrary fixtures, NOT approved game balance.
local function fixture(): Production.Config
	return {
		clearingRate = 4,
		transportRate = 3,
		processingRate = 2,
		outputCapacity = 5,
		processingCapacity = 3,
		maxStepSeconds = 1,
	}
end

local function near(actual: number, expected: number)
	assert(math.abs(actual - expected) < 1e-8, tostring(actual) .. " != " .. tostring(expected))
end

local cases = 0
local function test(name: string, run: () -> ())
	run()
	cases += 1
	print("PASS " .. name)
end

test("fractional rates, stage order and input immutability", function()
	local config = fixture()
	local state = Production.empty()
	local first = Production.step(config, state, 0.125)
	near(first.accepted, 0.5)
	near(first.transported, 0)
	near(first.processed, 0)
	near(state.output, 0)
	local second = Production.step(config, first.state, 0.125)
	near(second.transported, 0.375)
	near(second.processed, 0)
	local third = Production.step(config, second.state, 0.125)
	near(third.processed, 0.25)
	near(config.clearingRate, 4)
end)

test("zero elapsed is an identity transition", function()
	local state = { output = 2, processing = 1 }
	local result = Production.step(fixture(), state, 0)
	near(result.state.output, 2)
	near(result.state.processing, 1)
	near(result.accepted + result.transported + result.processed, 0)
end)

test("full downstream propagates backpressure and resumes without banked work", function()
	local config = fixture()
	config.processingRate = 0
	local state = Production.empty()
	local accepted = 0
	for _ = 1, 100 do
		local result = Production.step(config, state, 1)
		state = result.state
		accepted += result.accepted
	end
	near(accepted, 8)
	near(state.output, 5)
	near(state.processing, 3)
	near(Production.step(config, state, 1).accepted, 0)
	config.processingRate = 2
	local resumed = Production.step(config, state, 0.25)
	near(resumed.processed, 0.5)
	near(resumed.transported, 0.5)
	near(resumed.accepted, 0.5)
end)

test("zero capacity or disconnected transport stops admission at available storage", function()
	local config = fixture()
	config.processingCapacity = 0
	local state = Production.empty()
	for _ = 1, 10 do
		state = Production.step(config, state, 1).state
	end
	near(state.output, 5)
	near(state.processing, 0)
	config.outputCapacity = 0
	near(Production.step(config, Production.empty(), 1).accepted, 0)
	config = fixture()
	config.transportRate = 0
	near(Production.step(config, { output = 5, processing = 0 }, 1).accepted, 0)
end)

test("catch-up cap discards elapsed time without deferred production", function()
	local config = fixture()
	local result = Production.step(config, Production.empty(), 100)
	near(result.simulatedSeconds, 1)
	near(result.discardedSeconds, 99)
	near(result.accepted, 4)
	near(Production.step(config, result.state, 0).accepted, 0)
end)

test("deterministic repeated run conserves material and obeys rate/capacity bounds", function()
	local config = fixture()
	local state = Production.empty()
	local replay = Production.empty()
	local accepted, processed = 0, 0
	for index = 1, 2000 do
		local dt = (index % 7) * 0.037
		config.processingRate = if index % 19 < 7 then 0 else 2
		local result = Production.step(config, state, dt)
		local repeated = Production.step(config, replay, dt)
		state, replay = result.state, repeated.state
		accepted += result.accepted
		processed += result.processed
		near(state.output, replay.output)
		near(state.processing, replay.processing)
		assert(state.output >= 0 and state.output <= config.outputCapacity)
		assert(state.processing >= 0 and state.processing <= config.processingCapacity)
		assert(result.accepted <= config.clearingRate * dt)
		assert(result.transported <= config.transportRate * dt)
		assert(result.processed <= config.processingRate * dt)
		near(accepted, state.output + state.processing + processed)
	end
end)

test("invalid inputs fail without changing state", function()
	local state = { output = 1, processing = 1 }
	for _, invalid in { -1, math.huge, -math.huge, 0 / 0 } do
		for _, field in
			{
				"clearingRate",
				"transportRate",
				"processingRate",
				"outputCapacity",
				"processingCapacity",
				"maxStepSeconds",
			}
		do
			local config = fixture()
			local mutable: any = config
			mutable[field] = invalid
			assert(not pcall(Production.step, config, state, 1))
		end
		assert(not pcall(Production.step, fixture(), state, invalid))
		assert(not pcall(Production.step, fixture(), { output = invalid, processing = 0 }, 1))
		assert(not pcall(Production.step, fixture(), { output = 0, processing = invalid }, 1))
	end
	local config = fixture()
	config.maxStepSeconds = 0
	assert(not pcall(Production.step, config, state, 1))
	assert(not pcall(Production.step, fixture(), { output = 6, processing = 0 }, 1))
	assert(not pcall(Production.step, fixture(), { output = 0, processing = 4 }, 1))
	near(state.output, 1)
	near(state.processing, 1)
end)

-- Shared physical observation/event times, independent of the integration step.
-- Binary fractions keep event alignment exact; no catch-up time may be discarded.
type Sample = {
	output: number,
	processing: number,
	accepted: number,
	transported: number,
	processed: number,
}
type Scenario = { name: string, stable: boolean, blocked: boolean }
type SampleField = "output" | "processing" | "accepted" | "transported" | "processed"
local fields: { SampleField } = { "output", "processing", "accepted", "transported", "processed" }
local observations = {}
for index = 1, 40 do
	table.insert(observations, index * 0.5)
end
for _, time in { 4.375, 9.625, 9.75 } do
	table.insert(observations, time)
end
table.sort(observations)

local function trajectory(scenario: Scenario, step: number): { Sample }
	local config = fixture()
	config.maxStepSeconds = step
	if scenario.stable then
		config.clearingRate = 2
		config.transportRate = 4
		config.processingRate = 4
	end
	local state = Production.empty()
	local accepted, transported, processed, time = 0, 0, 0, 0
	local samples: { Sample } = {}
	for _, target in observations do
		while time < target do
			-- Events apply on [4.375, 9.625); observation at an event
			-- records the continuous state before any work at the new rate.
			if scenario.blocked then
				config.processingRate = if time >= 4.375 and time < 9.625 then 0 else 2
			end
			local dt = math.min(step, target - time)
			local previous = state
			local result = Production.step(config, state, dt)
			state = result.state
			accepted += result.accepted
			transported += result.transported
			processed += result.processed
			near(result.simulatedSeconds, dt)
			near(result.discardedSeconds, 0)
			assert(state.output >= 0 and state.output <= config.outputCapacity)
			assert(state.processing >= 0 and state.processing <= config.processingCapacity)
			assert(result.accepted >= 0 and result.accepted <= config.clearingRate * dt)
			assert(result.transported >= 0 and result.transported <= config.transportRate * dt)
			assert(result.processed >= 0 and result.processed <= config.processingRate * dt)
			near(previous.output + result.accepted, state.output + result.transported)
			near(previous.processing + result.transported, state.processing + result.processed)
			near(accepted - transported, state.output)
			near(transported - processed, state.processing)
			near(accepted, processed + state.output + state.processing)
			time += dt
		end
		table.insert(samples, {
			output = state.output,
			processing = state.processing,
			accepted = accepted,
			transported = transported,
			processed = processed,
		})
	end
	near(time, 20)
	return samples
end

-- Absolute infinity norm over ALL five quantities and ALL shared observations.
local function errorBetween(left: { Sample }, right: { Sample }): number
	assert(#left == #right)
	local maximum = 0
	for index, sample in left do
		for _, field in fields do
			maximum = math.max(maximum, math.abs(sample[field] - right[index][field]))
		end
	end
	return maximum
end

-- Independent zero-residence fluid solutions for these fixtures only.
-- At rates (4,3,2), Q grows at 1/s until t=3; O then grows at 2/s
-- until t=4. The later processor stall freezes already full queues.
local function fluidLimit(scenario: Scenario): { Sample }
	local samples: { Sample } = {}
	for _, time in observations do
		local active = time
		if scenario.blocked then
			active -= math.clamp(time - 4.375, 0, 9.625 - 4.375)
		end
		if scenario.stable then
			table.insert(samples, {
				output = 0,
				processing = 0,
				accepted = 2 * time,
				transported = 2 * time,
				processed = 2 * time,
			})
		else
			local processing = math.min(active, 3)
			local output = if active <= 3 then active else math.min(2 * active - 3, 5)
			local processed = 2 * active
			table.insert(samples, {
				output = output,
				processing = processing,
				accepted = processed + output + processing,
				transported = processed + processing,
				processed = processed,
			})
		end
	end
	return samples
end

for _, scenario: Scenario in
	{
		{ name = "stable flow", stable = true, blocked = false },
		{ name = "processor bottleneck", stable = false, blocked = false },
		{ name = "blocking and recovery", stable = false, blocked = true },
	}
do
	test("time refinement: " .. scenario.name, function()
		local limit = fluidLimit(scenario)
		local reference = trajectory(scenario, 1 / 1024)
		local finerReference = trajectory(scenario, 1 / 2048)
		local referenceGap = errorBetween(reference, finerReference)
		-- Two stage startup delays at <=4 units/s give a conservative
		-- 8*h envelope for these fixtures, not a universal model bound.
		assert(referenceGap <= 8 / 1024 + 1e-8)
		assert(errorBetween(reference, limit) <= 8 / 1024 + 1e-8)
		assert(errorBetween(finerReference, limit) <= 8 / 2048 + 1e-8)
		print(string.format("REF %s gap=%.9f", scenario.name, referenceGap))
		local previousError: number? = nil
		local previous: { Sample }? = nil
		for _, step in { 0.5, 0.25, 0.125, 0.0625, 0.03125 } do
			local samples = trajectory(scenario, step)
			local error = errorBetween(samples, limit)
			local referenceError = errorBetween(samples, reference)
			assert(error <= 8 * step + 1e-8, "fixture error envelope exceeded")
			if previousError then
				assert(
					error <= previousError * 0.6 + 1e-8,
					"refinement did not reduce error sufficiently"
				)
			end
			local pairGap = if previous
				then string.format("%.9f", errorBetween(samples, previous))
				else "n/a"
			print(
				string.format(
					"REFINE %s h=%.5f limit=%.9f reference=%.9f pair=%s",
					scenario.name,
					step,
					error,
					referenceError,
					pairGap
				)
			)
			local final = samples[#samples]
			if scenario.stable then
				-- Continuous zero-residence fluid limit: (A,T,P,O,Q)=(40,40,40,0,0).
				-- Startup loses two downstream-first steps: P=40-4*h.
				near(final.accepted, 40)
				near(final.output, 2 * step)
				near(final.processing, 2 * step)
				near(final.transported, 40 - 2 * step)
				near(final.processed, 40 - 4 * step)
			elseif not scenario.blocked then
				-- Processor starts at 2*h and then works at 2/s; both buffers saturate.
				near(final.processed, 40 - 4 * step)
				near(final.output, 5)
				near(final.processing, 3)
			else
				-- Long stall fills both buffers; no admission while fully blocked.
				local beforeIndex = table.find(observations, 9)
				local resumeIndex = table.find(observations, 9.625)
				local recoveredIndex = table.find(observations, 9.75)
				assert(beforeIndex and resumeIndex and recoveredIndex)
				local before = samples[beforeIndex]
				local resume = samples[resumeIndex]
				near(before.output, 5)
				near(before.processing, 3)
				near(resume.accepted, before.accepted)
				near(resume.processed, before.processed)
				local recovered = samples[recoveredIndex]
				near(recovered.processed - resume.processed, 0.25)
				near(recovered.accepted - resume.accepted, 0.25)
			end
			previousError, previous = error, samples
		end
	end)
end

print(tostring(cases) .. " production model tests passed")
