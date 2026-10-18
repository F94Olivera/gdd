--!strict
local Metrics = {}
export type Segment = {
	start: number,
	finish: number,
	rate: number,
	acceptedStart: number,
	acceptedFinish: number,
	onlineStart: number,
	manualStart: number?,
	manualActive: boolean?,
}

-- Eligible whole unit IDs are monotone floor(cumulative accepted), never per-step
-- rounding. The 1e-8 snap is numerical tolerance, not extra fractional credit.
function Metrics.whole(accepted: number): number
	return math.floor(accepted + 1e-8)
end

function Metrics.timeAt(segments: { Segment }, unit: number): (number, number, number)
	local lo, hi = 1, #segments
	while lo <= hi do
		local mid = math.floor((lo + hi) / 2)
		if segments[mid].acceptedFinish + 1e-8 < unit then
			lo = mid + 1
		else
			hi = mid - 1
		end
	end
	local s = segments[lo]
	assert(s and s.rate > 0, "unmapped work unit")
	local elapsed = math.max(0, (unit - s.acceptedStart) / s.rate)
	assert(elapsed <= s.finish - s.start + 1e-6, "time interpolation outside segment")
	return s.start + elapsed,
		s.onlineStart + elapsed,
		(s.manualStart or 0) + (if s.manualActive then elapsed else 0)
end

function Metrics.quantiles(values: { number }, n: number): any
	assert(#values == n, "censored observations must remain in denominator")
	table.sort(values)
	local out = {}
	for _, q in { 0.5, 0.9, 0.99 } do
		local index = math.ceil(n * q)
		local function readable(i: number): any
			local v = values[math.clamp(i, 1, n)]
			return if v < math.huge then v else "not reached"
		end
		out[tostring(q)] = {
			value = readable(index),
			-- Simultaneous 99% DKW band, conditional on ideal independent draws.
			lower = readable(math.ceil(n * math.max(0, q - math.sqrt(math.log(200) / (2 * n))))),
			upper = readable(math.ceil(n * math.min(1, q + math.sqrt(math.log(200) / (2 * n))))),
		}
	end
	return out
end

return Metrics
