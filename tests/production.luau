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

-- Transport fixtures use the same two-buffer line, capacities and 20 s horizon.
-- Independent fluid derivation: c=4, b=2, p=4>b, hence Q=0, T=P=2*active.
-- O grows at c-b=2 until full; during a stop it grows at c=4.
-- Stop at 11/8 (O=11/4), fill at 31/16, resume at 37/8.
local transportTimes: { number } = { 0 }
for index = 1, 160 do
	table.insert(transportTimes, index / 8)
end
for _, time in
	{
		21 / 16,
		11 / 8,
		23 / 16,
		30 / 16,
		31 / 16,
		32 / 16,
		39 / 16,
		40 / 16,
		41 / 16,
		73 / 16,
		37 / 8,
		75 / 16,
		76 / 16,
		77 / 16,
	}
do
	if not table.find(transportTimes, time) then
		table.insert(transportTimes, time)
	end
end
table.sort(transportTimes)

local function transportOracle(time: number, stopped: boolean): Sample
	local pause = if stopped then math.clamp(time - 11 / 8, 0, 26 / 8) else 0
	local transported = 2 * (time - pause)
	local output = math.min(2 * time + 2 * pause, 5)
	return {
		output = output,
		processing = 0,
		accepted = transported + output,
		transported = transported,
		processed = transported,
	}
end

local function transportTrajectory(step: number, stopped: boolean): { Sample }
	local config = fixture()
	config.transportRate, config.processingRate, config.maxStepSeconds = 2, 4, step
	local state = Production.empty()
	local time, accepted, transported, processed = 0, 0, 0, 0
	local samples: { Sample } = {}
	for _, target in transportTimes do
		while time < target do
			config.transportRate = if stopped and time >= 11 / 8 and time < 37 / 8 then 0 else 2
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

-- Separate each component and transition; cumulative startup offsets cannot mask
-- transition errors because we ALSO compare increments from each window's start.
local transportWindows = {
	{ name = "startup", first = 0, last = 1.3125 },
	{ name = "stop", first = 1.375, last = 2.125 },
	{ name = "saturation", first = 2.4375, last = 2.625 },
	{ name = "blocked", first = 3, last = 4.5625 },
	{ name = "restart", first = 4.625, last = 5.125 },
	{ name = "late", first = 6, last = 20 },
}
local function transportErrors(samples: { Sample }, stopped: boolean): { number }
	local errors: { number } = {}
	for _, window in transportWindows do
		local anchor = table.find(transportTimes, window.first)
		assert(anchor)
		local origin = transportOracle(window.first, stopped)
		for _, field in fields do
			local absolute, increment = 0, 0
			for index, time in transportTimes do
				if time >= window.first and time <= window.last then
					local expected = transportOracle(time, stopped)
					absolute = math.max(absolute, math.abs(samples[index][field] - expected[field]))
					increment = math.max(
						increment,
						math.abs(
							(samples[index][field] - samples[anchor][field])
								- (expected[field] - origin[field])
						)
					)
				end
			end
			table.insert(errors, absolute)
			table.insert(errors, increment)
		end
	end
	return errors
end

for _, stopped in { false, true } do
	test("transport refinement: " .. (if stopped then "stop/recovery" else "bottleneck"), function()
		local previous: { number }? = nil
		for _, step in { 1 / 16, 1 / 32, 1 / 64, 1 / 128, 1 / 256, 1 / 1024, 1 / 2048 } do
			local samples = transportTrajectory(step, stopped)
			local errors = transportErrors(samples, stopped)
			-- Fixture envelope: <= two stages * max rate * h absolute;
			-- anchored increments may subtract two such errors, hence 16*h.
			for index, error in errors do
				local bound = if index % 2 == 1 then 8 * step else 16 * step
				assert(error <= bound + 1e-8, "transport oracle envelope exceeded")
				if previous then
					local ratio = step / (if step == 1 / 1024 then 1 / 256 else step * 2)
					assert(
						error <= previous[index] * ratio * 1.2 + 1e-8,
						"transport component/window did not refine: " .. tostring(index)
					)
				end
			end
			local maxima = { 0, 0, 0, 0, 0 }
			for index, time in transportTimes do
				local expected = transportOracle(time, stopped)
				for fieldIndex, field in fields do
					maxima[fieldIndex] = math.max(
						maxima[fieldIndex],
						math.abs(samples[index][field] - expected[field])
					)
				end
			end
			print(
				string.format(
					"TRANSPORT stop=%s h=%.9f O=%.9f Q=%.9f A=%.9f T=%.9f P=%.9f",
					tostring(stopped),
					step,
					maxima[1],
					maxima[2],
					maxima[3],
					maxima[4],
					maxima[5]
				)
			)
			for windowIndex, window in transportWindows do
				local parts = {}
				for fieldIndex, field in fields do
					local offset = (windowIndex - 1) * 10 + (fieldIndex - 1) * 2
					table.insert(
						parts,
						string.format("%s=%.9f/%.9f", field, errors[offset + 1], errors[offset + 2])
					)
				end
				print("WINDOW " .. window.name .. " abs/delta " .. table.concat(parts, " "))
			end
			if stopped then
				local function at(t: number): Sample
					local index = table.find(transportTimes, t)
					assert(index)
					return samples[index]
				end
				near(at(4.625).transported, at(1.375).transported)
				near(at(4.625).processed - at(1.375).processed, 2 * step)
				near(at(4.5625).processing, 0)
				near(at(4.5625).output, 5)
				near(at(4.625).accepted, at(3).accepted)
				near(at(5.125).transported - at(4.625).transported, 1)
				near(at(5.125).accepted - at(4.625).accepted, 1)
				near(at(5.125).processed - at(4.625).processed, 1 - 2 * step)
			end
			previous = errors
		end
	end)
end

-- Nonempty fixtures: closed-form discrete oracle, not a fine-run reference.
local smallCapacity = 1 / 16
local initialTimes = { 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6 }
local initialWindows = {
	{ first = 0, last = 0.5, name = "initial" },
	{ first = 0.5, last = 1, name = "drain-tail" },
	{ first = 1, last = 2, name = "before-stop" },
	{ first = 2, last = 4, name = "stopped" },
	{ first = 4, last = 4.5, name = "restart" },
	{ first = 4.5, last = 6, name = "late" },
}

local function initialOracle(time: number, step: number?, drain: boolean): Sample
	local speed = if step then math.min(2, smallCapacity / step) else 2
	if drain then
		-- Q stays full until O empties at 1/speed; then drains at 2/s.
		local transported = math.min(speed * time, 1)
		local processed = transported + math.clamp(2 * (time - 1 / speed), 0, smallCapacity)
		return {
			output = 1 - transported,
			processing = smallCapacity + transported - processed,
			accepted = 0,
			transported = transported,
			processed = processed,
		}
	end
	local active = time - math.clamp(time - 2, 0, 2)
	return {
		output = 1,
		processing = smallCapacity,
		accepted = speed * active,
		transported = speed * active,
		processed = speed * active,
	}
end

for _, drain in { true, false } do
	test(
		"nonempty small downstream: " .. (if drain then "drain" else "full stop/restart"),
		function()
			for _, step in { 1 / 4, 1 / 8, 1 / 16, 1 / 32, 1 / 64, 1 / 128, 1 / 256 } do
				local config: Production.Config = {
					clearingRate = if drain then 0 else 4,
					transportRate = 2,
					processingRate = 2,
					outputCapacity = if drain then 2 else 1,
					processingCapacity = smallCapacity,
					maxStepSeconds = step,
				}
				local state = { output = 1, processing = smallCapacity }
				local accepted, transported, processed, time = 0, 0, 0, 0
				local samples: { Sample } = {}
				for _, target in initialTimes do
					while time < target do
						config.processingRate = if not drain
								and time >= 2
								and time < 4
							then 0
							else 2
						-- All targets and events are on EVERY grid; observations never subdivide h.
						assert(time + step <= target)
						local previous = state
						local result = Production.step(config, state, step)
						state = result.state
						accepted += result.accepted
						transported += result.transported
						processed += result.processed
						near(result.simulatedSeconds, step)
						near(result.discardedSeconds, 0)
						near(result.simulatedSeconds + result.discardedSeconds, step)
						assert(state.output >= 0 and state.output <= config.outputCapacity)
						assert(
							state.processing >= 0 and state.processing <= config.processingCapacity
						)
						assert(
							result.accepted >= 0 and result.accepted <= config.clearingRate * step
						)
						assert(
							result.transported >= 0
								and result.transported <= config.transportRate * step
						)
						assert(
							result.processed >= 0
								and result.processed <= config.processingRate * step
						)
						near(previous.output + result.accepted, state.output + result.transported)
						near(
							previous.processing + result.transported,
							state.processing + result.processed
						)
						near(1 + accepted - transported, state.output)
						near(smallCapacity + transported - processed, state.processing)
						near(
							1 + smallCapacity + accepted,
							state.output + state.processing + processed
						)
						time += step
						-- Exact discrete prediction at every transition, including unobserved drain times.
						local discrete = initialOracle(time, step, drain)
						near(state.output, discrete.output)
						near(state.processing, discrete.processing)
						near(accepted, discrete.accepted)
						near(transported, discrete.transported)
						near(processed, discrete.processed)
					end
					table.insert(samples, {
						output = state.output,
						processing = state.processing,
						accepted = accepted,
						transported = transported,
						processed = processed,
					})
				end
				near(time, 6)
				for _, window in initialWindows do
					local anchor = table.find(initialTimes, window.first)
					assert(anchor)
					local origin = initialOracle(window.first, nil, drain)
					local parts = {}
					for _, field in fields do
						local absolute, increment = 0, 0
						local predictedAbsolute, predictedIncrement = 0, 0
						for index, t in initialTimes do
							if t >= window.first and t <= window.last then
								local fluid = initialOracle(t, nil, drain)
								local discrete = initialOracle(t, step, drain)
								local discreteOrigin = initialOracle(window.first, step, drain)
								absolute = math.max(
									absolute,
									math.abs(samples[index][field] - fluid[field])
								)
								increment = math.max(
									increment,
									math.abs(
										samples[index][field]
											- samples[anchor][field]
											- fluid[field]
											+ origin[field]
									)
								)
								predictedAbsolute = math.max(
									predictedAbsolute,
									math.abs(discrete[field] - fluid[field])
								)
								predictedIncrement = math.max(
									predictedIncrement,
									math.abs(
										discrete[field]
											- discreteOrigin[field]
											- fluid[field]
											+ origin[field]
									)
								)
							end
						end
						-- Assert the actual error profile, without assuming monotone refinement.
						near(absolute, predictedAbsolute)
						near(increment, predictedIncrement)
						table.insert(
							parts,
							string.format("%s=%.9f/%.9f", field, absolute, increment)
						)
					end
					print(
						string.format(
							"INITIAL drain=%s h=%.9f %s abs/delta %s",
							tostring(drain),
							step,
							window.name,
							table.concat(parts, " ")
						)
					)
				end
			end
		end
	)
end

-- Partial inventories: closed cumulative envelopes, independent of step implementation.
local partialTimes = {
	0,
	0.2,
	0.24,
	0.26,
	0.4,
	0.48,
	0.5,
	0.52,
	0.6,
	0.8,
	0.82,
	0.9,
	1,
	1.2,
	1.9,
	2,
	2.1,
	2.9,
	3,
	3.1,
	4,
}
local partialWindows = {
	{ first = 0, last = 0.4, name = "interior-fill/drain" },
	{ first = 0.4, last = 0.9, name = "stop/supply-tail" },
	{ first = 0.9, last = 1.2, name = "recovery" },
	{ first = 1.2, last = 2.1, name = "output-empty" },
	{ first = 2.1, last = 3.1, name = "processing-empty" },
	{ first = 3.1, last = 4, name = "empty" },
}

local function partialOracle(t: number, filling: boolean): Sample
	local transported, processed, initialOutput, initialProcessing
	if filling then
		initialOutput, initialProcessing = 2, 0.5
		local active = t - math.clamp(t - 0.4, 0, 0.5)
		-- Initial Q covers service until transport starts; thereafter Q fills.
		processed = math.min(active, 2.5)
		transported = math.min(2, 3 * t, 0.5 + processed)
	else
		initialOutput, initialProcessing = 0.8, 1
		transported = math.min(t, 0.8)
		-- Fluid service is bounded by cumulative supply.
		processed = math.min(3 * t, 1 + math.min(t, 0.8))
	end
	return {
		output = initialOutput - transported,
		processing = initialProcessing + transported - processed,
		accepted = 0,
		transported = transported,
		processed = processed,
	}
end

for _, filling in { true, false } do
	test(
		"partial unequal rates: "
			.. (if filling then "fill/stop/recover/drain" else "interior depletion"),
		function()
			for _, h in { 0.07, 0.035, 0.0175, 0.00875 } do
				local config: Production.Config = {
					clearingRate = 0,
					transportRate = if filling then 3 else 1,
					processingRate = if filling then 1 else 3,
					outputCapacity = 3,
					processingCapacity = if filling then 1 else 2,
					maxStepSeconds = h,
				}
				local initial = partialOracle(0, filling)
				local state = { output = initial.output, processing = initial.processing }
				local time, transported, processed, transitions = 0, 0, 0, 0
				local serviceEnvelope = math.huge
				local samples: { Sample } = {}
				local predictions: { Sample } = {}
				local prediction = initial
				for _, target in partialTimes do
					while target - time > 1e-12 do
						config.processingRate = if filling
								and time >= 0.4
								and time < 0.9
							then 0
							else (if filling then 1 else 3)
						local dt = math.min(h, target - time)
						local before = state
						local result = Production.step(config, state, dt)
						state = result.state
						transported += result.transported
						processed += result.processed
						near(result.simulatedSeconds, dt)
						near(result.discardedSeconds, 0)
						near(result.simulatedSeconds + result.discardedSeconds, dt)
						near(result.accepted, 0)
						assert(
							result.transported >= 0
								and result.transported <= config.transportRate * dt + 1e-8
						)
						assert(
							result.processed >= 0
								and result.processed <= config.processingRate * dt + 1e-8
						)
						assert(state.output >= 0 and state.output <= config.outputCapacity)
						assert(
							state.processing >= 0 and state.processing <= config.processingCapacity
						)
						near(before.output, state.output + result.transported)
						near(
							before.processing + result.transported,
							state.processing + result.processed
						)
						near(initial.output - transported, state.output)
						near(initial.processing + transported - processed, state.processing)
						near(
							initial.output + initial.processing,
							state.output + state.processing + processed
						)
						local expected = partialOracle(time + dt, filling)
						if not filling then
							-- Closed min-plus envelope over earlier arrival/service boundaries.
							-- A short observation step can leave backlog for later steps.
							serviceEnvelope =
								math.min(serviceEnvelope, 1 + math.min(time, 0.8) - 3 * (time + dt))
							expected.processed =
								math.min(3 * (time + dt), 3 * (time + dt) + serviceEnvelope)
							expected.processing = 1 + expected.transported - expected.processed
						end
						prediction = expected
						near(state.output, expected.output)
						near(state.processing, expected.processing)
						near(transported, expected.transported)
						near(processed, expected.processed)
						time += dt
						transitions += 1
					end
					table.insert(predictions, prediction)
					time = target -- Remove floating-point clock drift only at shared boundaries.
					table.insert(samples, {
						output = state.output,
						processing = state.processing,
						accepted = 0,
						transported = transported,
						processed = processed,
					})
				end
				near(time, 4)
				for _, window in partialWindows do
					local anchor = table.find(partialTimes, window.first)
					assert(anchor)
					local origin = partialOracle(window.first, filling)
					local parts = {}
					for _, field in fields do
						local absolute, increment = 0, 0
						local predictedAbsolute, predictedIncrement = 0, 0
						for index, t in partialTimes do
							if t >= window.first and t <= window.last then
								local fluid = partialOracle(t, filling)
								predictedAbsolute = math.max(
									predictedAbsolute,
									math.abs(predictions[index][field] - fluid[field])
								)
								predictedIncrement = math.max(
									predictedIncrement,
									math.abs(
										predictions[index][field]
											- predictions[anchor][field]
											- fluid[field]
											+ origin[field]
									)
								)
								absolute = math.max(
									absolute,
									math.abs(samples[index][field] - fluid[field])
								)
								increment = math.max(
									increment,
									math.abs(
										samples[index][field]
											- samples[anchor][field]
											- fluid[field]
											+ origin[field]
									)
								)
							end
						end
						near(absolute, predictedAbsolute)
						near(increment, predictedIncrement)
						assert(absolute <= 3 * h + 1e-8)
						assert(increment <= 6 * h + 1e-8)
						table.insert(
							parts,
							string.format("%s=%.9f/%.9f", field, absolute, increment)
						)
					end
					print(
						string.format(
							"PARTIAL fill=%s h=%.5f %s abs/delta %s",
							tostring(filling),
							h,
							window.name,
							table.concat(parts, " ")
						)
					)
				end
				print(
					string.format(
						"PARTIAL transitions fill=%s h=%.5f n=%d",
						tostring(filling),
						h,
						transitions
					)
				)
			end
		end
	)
end

print(tostring(cases) .. " production model tests passed")
