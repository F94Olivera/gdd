--!strict
-- Offline natural-event stream: Park-Miller 16807 / modulus 2147483647.
-- Integer products remain below 2^53. Not a gameplay RNG recommendation.
local Discovery = {}
export type State = {
	rng: number,
	nextNatural: number,
	unit: number,
	failures: number,
	archives: number,
}
local MODULUS = 2147483647

function Discovery.uniform(seed: number): (number, number)
	assert(seed >= 1 and seed < MODULUS and seed % 1 == 0, "invalid seed")
	local nextSeed = (seed * 16807) % MODULUS
	return nextSeed, nextSeed / MODULUS
end

local function gap(seed: number): (number, number)
	local nextSeed, u = Discovery.uniform(seed)
	return nextSeed, math.floor(math.log(1 - u) / math.log(1 - 0.00001)) + 1
end

function Discovery.new(seed: number): State
	local rng, distance = gap(seed)
	return { rng = rng, nextNatural = distance, unit = 0, failures = 0, archives = 0 }
end

-- Advance only newly accepted WHOLE units. Fractions belong to the caller.
-- The next natural event is absolute in work units. A guarantee consumes no draw,
-- so both policies see exactly the same natural sequence at the same unit IDs.
function Discovery.advance(s: State, units: number, guaranteed: boolean): { number }
	assert(units >= 0 and units % 1 == 0 and units < math.huge, "whole units required")
	assert(s.failures >= 0 and (not guaranteed or s.failures < 200000), "invalid failure counter")
	local finish = s.unit + units
	local awards = {}
	while s.unit < finish do
		local forced = if guaranteed then s.unit + 200000 - s.failures else math.huge
		local event = math.min(s.nextNatural, forced)
		if event > finish then
			s.failures += finish - s.unit
			s.unit = finish
			break
		end
		s.failures += event - s.unit
		s.unit = event
		s.archives += 1
		s.failures = 0
		table.insert(awards, event)
		if s.nextNatural == event then
			local rng, distance = gap(s.rng)
			s.rng = rng
			s.nextNatural += distance
		end
	end
	return awards
end

return Discovery
