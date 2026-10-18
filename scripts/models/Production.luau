--!strict
-- Offline continuous-quantity model; no Roblox, discovery, currency or wall clock.
local Production = {}

export type Config = {
	clearingRate: number,
	transportRate: number,
	processingRate: number,
	outputCapacity: number,
	processingCapacity: number,
	maxStepSeconds: number,
}

export type State = {
	output: number,
	processing: number,
}

export type Result = {
	state: State,
	accepted: number,
	transported: number,
	processed: number,
	simulatedSeconds: number,
	discardedSeconds: number,
}

local function nonnegative(value: number, name: string)
	assert(
		type(value) == "number" and value == value and value >= 0 and value < math.huge,
		name .. " must be finite and nonnegative"
	)
end

function Production.empty(): State
	return { output = 0, processing = 0 }
end

-- Caller supplies all experiment parameters. Inputs are never mutated.
-- Downstream-first: arrivals cannot traverse two stages within the same step.
-- Unused rate capacity expires each step; blocked time never banks future work.
function Production.step(config: Config, state: State, elapsedSeconds: number): Result
	-- Check named fields: a missing field must fail before arithmetic.
	nonnegative(config.clearingRate, "clearingRate")
	nonnegative(config.transportRate, "transportRate")
	nonnegative(config.processingRate, "processingRate")
	nonnegative(config.outputCapacity, "outputCapacity")
	nonnegative(config.processingCapacity, "processingCapacity")
	nonnegative(config.maxStepSeconds, "maxStepSeconds")
	assert(config.maxStepSeconds > 0, "maxStepSeconds must be positive")
	nonnegative(state.output, "output")
	nonnegative(state.processing, "processing")
	assert(state.output <= config.outputCapacity, "output exceeds capacity")
	assert(state.processing <= config.processingCapacity, "processing exceeds capacity")
	nonnegative(elapsedSeconds, "elapsedSeconds")

	local dt = math.min(elapsedSeconds, config.maxStepSeconds)
	local processed = math.min(state.processing, config.processingRate * dt)
	local processing = state.processing - processed
	local transported =
		math.min(state.output, config.transportRate * dt, config.processingCapacity - processing)
	processing += transported
	local output = state.output - transported
	local accepted = math.min(config.clearingRate * dt, config.outputCapacity - output)
	output += accepted

	return {
		state = { output = output, processing = processing },
		accepted = accepted,
		transported = transported,
		processed = processed,
		simulatedSeconds = dt,
		discardedSeconds = elapsedSeconds - dt,
	}
end

return Production
