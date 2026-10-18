--!strict
-- Experimental offline scheduler. Never required by the Rojo runtime.
local Production = require("./Production")
local Runner = {}

export type Window = { start: number, finish: number }
export type Line = {
	id: string,
	config: Production.Config,
	state: Production.State,
	maximumExtractor: boolean?,
}
export type Event = { id: string, time: number, line: string, patch: { [string]: number } }
export type Scenario = {
	id: string,
	horizon: number,
	h: number,
	sessions: { Window },
	lines: { Line },
	events: { Event },
	observations: { number },
}

local function finite(x: number)
	assert(type(x) == "number" and x == x and x >= 0 and x < math.huge, "invalid number")
end

function Runner.validate(s: Scenario)
	assert(type(s.id) == "string" and #s.id > 0, "missing scenario id")
	finite(s.horizon)
	finite(s.h)
	assert(s.h > 0 and s.horizon > 0, "positive horizon/step required")
	local ids = {}
	local configs = {}
	local maximumExtractors = 0
	for _, line in s.lines do
		assert(not ids[line.id], "duplicate line")
		ids[line.id] = true
		if line.maximumExtractor then
			maximumExtractors += 1
		end
		configs[line.id] = table.clone(line.config)
		Production.step(line.config, line.state, 0)
	end
	assert(#s.lines > 0, "no lines")
	assert(maximumExtractors <= 2, "third maximum extractor prohibited")
	local last = 0
	for _, window in s.sessions do
		finite(window.start)
		finite(window.finish)
		assert(
			window.start >= last and window.finish > window.start and window.finish <= s.horizon,
			"invalid sessions"
		)
		last = window.finish
	end
	local eventIds = {}
	local changed = {}
	local events = table.clone(s.events)
	table.sort(events, function(a, b)
		return if a.time == b.time then a.id < b.id else a.time < b.time
	end)
	for _, event in events do
		finite(event.time)
		assert(
			event.time <= s.horizon and ids[event.line] and not eventIds[event.id],
			"invalid event"
		)
		eventIds[event.id] = true
		local config = configs[event.line]
		for key, value in event.patch do
			assert(config[key] ~= nil, "unknown config field")
			finite(value)
			local token = tostring(event.time) .. ":" .. event.line .. ":" .. key
			assert(not changed[token], "conflicting simultaneous patches")
			changed[token] = true
			if key == "outputCapacity" or key == "processingCapacity" then
				assert(value >= config[key], "capacity reduction is not supported")
			end
			config[key] = value
		end
		Production.step(config, Production.empty(), 0)
	end
	last = -1
	for _, t in s.observations do
		finite(t)
		assert(t > last and t <= s.horizon, "invalid observations")
		last = t
	end
end

function Runner.run(s: Scenario): any
	Runner.validate(s)
	local lines = {}
	local initial = 0
	for _, line in s.lines do
		table.insert(
			lines,
			{ id = line.id, config = table.clone(line.config), state = table.clone(line.state) }
		)
		initial += line.state.output + line.state.processing
	end
	table.sort(lines, function(a, b)
		return a.id < b.id
	end)
	local boundaries = { 0, s.horizon }
	for _, w in s.sessions do
		table.insert(boundaries, w.start)
		table.insert(boundaries, w.finish)
	end
	for _, e in s.events do
		table.insert(boundaries, e.time)
	end
	for _, t in s.observations do
		table.insert(boundaries, t)
	end
	table.sort(boundaries)
	local unique = {}
	for _, t in boundaries do
		if unique[#unique] ~= t then
			table.insert(unique, t)
		end
	end
	local events = table.clone(s.events)
	table.sort(events, function(a, b)
		return if a.time == b.time then a.id < b.id else a.time < b.time
	end)
	local totals = {
		accepted = 0,
		transported = 0,
		processed = 0,
		online = 0,
		simulated = 0,
		discarded = 0,
		deficit = 0,
		constrained = 0,
	}
	local metrics = {}
	for _, line in lines do
		metrics[line.id] = {
			outputArea = 0,
			processingArea = 0,
			outputMax = line.state.output,
			processingMax = line.state.processing,
			outputFull = 0,
			processingFull = 0,
		}
	end
	local rows = {}
	local segments = {}
	local eventIndex = 1
	for index, start in unique do
		while events[eventIndex] and events[eventIndex].time == start do
			local e = events[eventIndex]
			for _, line in lines do
				if line.id == e.line then
					for key, value in e.patch do
						line.config[key] = value
					end
				end
			end
			eventIndex += 1
		end
		local inventory = 0
		local states = {}
		for _, line in lines do
			inventory += line.state.output + line.state.processing
			table.insert(
				states,
				{ id = line.id, output = line.state.output, processing = line.state.processing }
			)
		end
		assert(
			math.abs(initial + totals.accepted - totals.processed - inventory) < 1e-6,
			"cumulative conservation"
		)
		table.insert(rows, { time = start, totals = table.clone(totals), lines = states })
		local finish = unique[index + 1]
		if not finish then
			break
		end
		local online = false
		for _, w in s.sessions do
			if start >= w.start and start < w.finish then
				online = true
			end
		end
		if not online then
			continue
		end
		local time = start
		while time < finish do
			local dt = math.min(s.h, finish - time)
			-- No banking: stable ID priority consumes a fresh shared 60*simulated-dt budget.
			local cap = math.huge
			for _, line in lines do
				cap = math.min(cap, line.config.maxStepSeconds)
			end
			local simulated = math.min(dt, cap)
			local budget = 60 * simulated
			local constrained = false
			local acceptedBefore = totals.accepted
			for _, line in lines do
				local config = table.clone(line.config)
				config.maxStepSeconds = cap
				local demand = config.clearingRate * simulated
				config.clearingRate = math.min(config.clearingRate, budget / simulated)
				local before = line.state
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
				assert(
					r.state.output >= 0 and r.state.output <= config.outputCapacity,
					"output capacity"
				)
				assert(
					r.state.processing >= 0 and r.state.processing <= config.processingCapacity,
					"processing capacity"
				)
				budget -= r.accepted
				totals.accepted += r.accepted
				totals.transported += r.transported
				totals.processed += r.processed
				totals.deficit += demand - r.accepted
				constrained = constrained or r.accepted < demand - 1e-10
				local m = metrics[line.id]
				-- Left-endpoint occupancy quadrature; full fraction is sampled, not exact continuous time.
				m.outputArea += before.output * simulated
				m.processingArea += before.processing * simulated
				m.outputFull += if before.output >= config.outputCapacity - 1e-10
					then simulated
					else 0
				m.processingFull += if before.processing
						>= config.processingCapacity - 1e-10
					then simulated
					else 0
				m.outputMax = math.max(m.outputMax, r.state.output)
				m.processingMax = math.max(m.processingMax, r.state.processing)
				line.state = r.state
			end
			assert(budget >= -1e-8, "global cap")
			local rate = (totals.accepted - acceptedBefore) / simulated
			local previous = segments[#segments]
			if previous and previous.finish == time and math.abs(previous.rate - rate) < 1e-10 then
				previous.finish = time + simulated
				previous.acceptedFinish = totals.accepted
			else
				table.insert(segments, {
					start = time,
					finish = time + simulated,
					rate = rate,
					acceptedStart = acceptedBefore,
					acceptedFinish = totals.accepted,
					onlineStart = totals.online,
				})
			end
			totals.online += dt
			totals.simulated += simulated
			totals.discarded += dt - simulated
			if constrained then
				totals.constrained += simulated
			end
			time = math.min(finish, time + dt)
		end
	end
	return { id = s.id, rows = rows, segments = segments, totals = totals, metrics = metrics }
end

return Runner
