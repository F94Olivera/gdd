--!strict
-- M1-03: Ground conveyor graph, transactional edits and inventory-safe topology changes.
local Graph = require("../src/server/PlotGraph")
local Ledger = require("../src/server/ProductionLedger")
local Catalog = require("../src/shared/Catalog")
local defs = Catalog.definitions
local rates = Catalog.beltRates(defs)

-- Graph rules are tested on a fixed fixture (the original D-023 placeholder), so
-- moving the catalog's pile or bays (D-024) is a data change, not a test rewrite.
-- Section 8 checks the catalog's own layout.
local layout = {
	gridWidth = 16,
	gridDepth = 16,
	cellStuds = 4,
	blockedCells = {},
	pile = { x = 0, z = 6, width = 3, depth = 3 },
	bays = {
		{
			id = "bay_1",
			price = 0,
			source = {
				footprint = { x = 3, z = 3, width = 2, depth = 2 },
				outPort = { x = 4, z = 3, direction = 1 },
			},
			processor = {
				footprint = { x = 12, z = 3, width = 2, depth = 2 },
				inPort = { x = 12, z = 3, direction = 1 },
			},
		},
		{
			id = "bay_2",
			price = 0,
			source = {
				footprint = { x = 3, z = 11, width = 2, depth = 2 },
				outPort = { x = 4, z = 11, direction = 1 },
			},
			processor = {
				footprint = { x = 12, z = 11, width = 2, depth = 2 },
				inPort = { x = 12, z = 11, direction = 1 },
			},
		},
	},
	starterBay = "bay_1",
	starterBeltTier = defs.layout.starterBeltTier,
	starterBelts = {
		{ x = 5, z = 3, kind = "straight", rotation = 1 },
		{ x = 6, z = 3, kind = "straight", rotation = 1 },
		{ x = 7, z = 3, kind = "straight", rotation = 1 },
		{ x = 8, z = 3, kind = "straight", rotation = 1 },
		{ x = 9, z = 3, kind = "straight", rotation = 1 },
		{ x = 10, z = 3, kind = "straight", rotation = 1 },
		{ x = 11, z = 3, kind = "straight", rotation = 1 },
	},
}

local function belt(
	id: string,
	x: number,
	z: number,
	kind: string,
	rotation: number,
	tier: string?
): Graph.Belt
	return {
		id = id,
		x = x,
		z = z,
		kind = kind :: Graph.BeltKind,
		rotation = rotation,
		tier = tier or "belt_t1",
		paid = 5,
	}
end

local function ok(state: Graph.State, edit: Graph.Edit): Graph.State
	local success, result = Graph.apply(layout, rates, state, edit)
	assert(success, "edit rejected: " .. tostring(result))
	return result
end

local function rejects(state: Graph.State, edit: any, code: string)
	local before = table.clone(state.belts)
	local revision = state.revision
	local success, result = Graph.apply(layout, rates, state, edit)
	assert(not success and result == code, "expected " .. code .. ", got " .. tostring(result))
	-- Atomic: the old state is untouched.
	assert(state.revision == revision)
	for id, b in before do
		assert(state.belts[id] == b)
	end
end

-- 1. The fresh plot has the free 1/s starter connection on bay_1 only.
local start = Graph.new(layout, rates)
local lines = Graph.lines(layout, start)
assert(lines.bay_1.connected and #lines.bay_1.belts == 7)
assert(Graph.transportRate(lines.bay_1, start, rates) == 1)
assert(not lines.bay_2.connected and lines.bay_2.reason == "no_belt")
assert(Graph.transportRate(lines.bay_2, start, rates) == 0)

-- 2. Routing bay_2 with straight and corner belts, then the slowest belt sets the rate.
local s = start
s = ok(s, { op = "place", belt = belt("a", 5, 11, "straight", 1) })
assert(Graph.lines(layout, s).bay_2.reason == "dangling")
-- Detour: east, turn north (left), east, turn south (right), east to the port.
s = ok(s, { op = "place", belt = belt("b", 6, 11, "corner_left", 0) })
s = ok(s, { op = "place", belt = belt("c", 6, 10, "corner_right", 1) })
for x = 7, 9 do
	s = ok(s, { op = "place", belt = belt("d" .. x, x, 10, "straight", 1) })
end
s = ok(s, { op = "place", belt = belt("e", 10, 10, "corner_right", 2) })
s = ok(s, { op = "place", belt = belt("f", 10, 11, "corner_left", 1) })
s = ok(s, { op = "place", belt = belt("g", 11, 11, "straight", 1, "belt_t2") })
local routed = Graph.lines(layout, s).bay_2
assert(routed.connected and #routed.belts == 9, routed.reason)
assert(Graph.transportRate(routed, s, rates) == 10, "slowest belt limits the line")
assert(s.revision == 9)

-- 3. Invalid edits are rejected atomically with a specific code.
rejects(s, { op = "place", belt = belt("x", 16, 0, "straight", 1) }, "out_of_bounds")
rejects(s, { op = "place", belt = belt("x", -1, 0, "straight", 1) }, "out_of_bounds")
rejects(s, { op = "place", belt = belt("x", 1, 7, "straight", 1) }, "occupied") -- pile
rejects(s, { op = "place", belt = belt("x", 3, 3, "straight", 1) }, "occupied") -- source slot
rejects(s, { op = "place", belt = belt("x", 5, 3, "straight", 1) }, "occupied") -- starter belt
rejects(s, { op = "place", belt = belt("starter_1", 0, 0, "straight", 1) }, "duplicate_id")
rejects(s, { op = "place", belt = belt("x", 0, 0, "straight", 0) }, "invalid_port") -- off grid
rejects(s, { op = "place", belt = belt("x", 2, 5, "straight", 2) }, "invalid_port") -- into the pile
-- Side-on into the starter line, and a belt facing the wrong way at a port.
rejects(s, { op = "place", belt = belt("x", 6, 2, "straight", 2) }, "invalid_port")
rejects(s, { op = "place", belt = belt("x", 5, 4, "straight", 3) }, "invalid_port") -- into the source wall
rejects(s, { op = "place", belt = belt("x", 14, 5, "straight", 1, "belt_gold") }, "invalid_tier")
rejects(s, { op = "place", belt = belt("x", 14, 5, "splitter", 1) }, "invalid_shape")
rejects(s, { op = "place", belt = belt("x", 14, 5, "straight", 4) }, "invalid_shape")
rejects(s, { op = "place", belt = belt("x", 14.5, 5, "straight", 1) }, "out_of_bounds")
rejects(s, { op = "place", belt = belt("x", 0 / 0, 5, "straight", 1) }, "out_of_bounds")
rejects(s, { op = "place", belt = belt("Bad-Id", 14, 5, "straight", 1) }, "invalid_id")
rejects(s, { op = "place", belt = belt(string.rep("a", 33), 14, 5, "straight", 1) }, "invalid_id")
rejects(s, { op = "remove", id = "missing" }, "unknown_belt")
rejects(s, { op = "move", id = "missing", x = 1, z = 1, rotation = 0 }, "unknown_belt")
rejects(s, { op = "teleport" }, "invalid_edit")
rejects(s, "remove everything", "invalid_edit")

-- 4. Cycles: four corners forming a loop are rejected at the closing edit.
do
	local loop = start
	loop = ok(loop, { op = "place", belt = belt("l1", 7, 7, "corner_left", 0) })
	loop = ok(loop, { op = "place", belt = belt("l2", 7, 6, "corner_left", 3) })
	loop = ok(loop, { op = "place", belt = belt("l3", 6, 6, "corner_left", 2) })
	rejects(loop, { op = "place", belt = belt("l4", 6, 7, "corner_left", 1) }, "cycle")
end

-- 5. Cross-bay routing is rejected in M1: bay_2's source cannot feed bay_1's processor.
do
	local cross = start
	for _, id in { "starter_5", "starter_6", "starter_7" } do
		cross = ok(cross, { op = "remove", id = id })
	end
	for x = 5, 9 do
		cross = ok(cross, { op = "place", belt = belt("cx" .. x, x, 11, "straight", 1) })
	end
	cross = ok(cross, { op = "place", belt = belt("turn_up", 10, 11, "corner_left", 0) })
	for z = 10, 4, -1 do
		cross = ok(cross, { op = "place", belt = belt("cz" .. z, 10, z, "straight", 0) })
	end
	cross = ok(cross, { op = "place", belt = belt("turn_east", 10, 3, "corner_right", 1) })
	rejects(cross, { op = "place", belt = belt("last", 11, 3, "straight", 1) }, "cross_bay")
end

-- 6. Move and rotate keep identity, tier and recorded price; replays are rejected.
do
	local moved = ok(s, { op = "move", id = "g", x = 11, z = 11, rotation = 1 })
	assert(moved.belts.g.tier == "belt_t2" and moved.belts.g.paid == 5)
	-- Turning the first belt side-on to the source port is rejected...
	rejects(s, { op = "move", id = "a", x = 5, z = 11, rotation = 0 }, "invalid_port")
	-- ...while a loose belt rotates and moves freely, keeping its id.
	local loose = ok(s, { op = "place", belt = belt("loose", 14, 14, "straight", 0) })
	local turned = ok(loose, { op = "move", id = "loose", x = 14, z = 14, rotation = 2 })
	assert(turned.belts.loose.rotation == 2 and loose.belts.loose.rotation == 0)
	local shifted = ok(turned, { op = "move", id = "loose", x = 15, z = 13, rotation = 2 })
	assert(shifted.belts.loose.x == 15 and shifted.revision == turned.revision + 1)
	local removed = ok(s, { op = "remove", id = "d8" })
	rejects(removed, { op = "remove", id = "d8" }, "unknown_belt")
	assert(Graph.lines(layout, removed).bay_2.reason == "dangling")
	-- The original state still has the belt: edits never mutate their input.
	assert(s.belts.d8 ~= nil and s.revision == 9)
end

-- 7. Topology edits conserve inventory and never re-issue unit IDs (T-005).
do
	local limits = Catalog.productionLimits(defs)
	local buffer = defs.simulation.lineBufferUnits
	local function lineConfig(state: Graph.State): { Ledger.LineConfig }
		local status = Graph.lines(layout, state).bay_1
		return {
			{
				id = "bay_1",
				clearingRate = 30,
				transportRate = Graph.transportRate(status, state, rates),
				processingRate = 40,
				outputCapacity = buffer,
				processingCapacity = buffer,
			},
		}
	end
	local function runFor(graph: Graph.State, ledger: Ledger.State, ticks: number): Ledger.State
		for _ = 1, ticks do
			local r = Ledger.advance(limits, lineConfig(graph), ledger, 0.2)
			ledger = Ledger.confirm(r.state, r.state.assignedUnits)
		end
		return ledger
	end
	local graph = start
	local ledger = runFor(graph, Ledger.new(), 50)
	local function held(l: Ledger.State): number
		return l.lines.bay_1.output + l.lines.bay_1.processing
	end
	-- Remove a starter belt mid-flow: the line disconnects, nothing is lost.
	local before = ledger.accepted - ledger.processed
	graph = ok(graph, { op = "remove", id = "starter_4" })
	assert(not Graph.lines(layout, graph).bay_1.connected)
	assert(math.abs(held(ledger) - before) < 1e-9)
	local stalled = runFor(graph, ledger, 50)
	-- Clearing stops once the output buffer is full; processing drains.
	assert(stalled.lines.bay_1.output == buffer and stalled.lines.bay_1.processing == 0)
	assert(math.abs(stalled.accepted - stalled.processed - held(stalled)) < 1e-6)
	local frozen = stalled.assignedUnits
	local idle = runFor(graph, stalled, 10)
	assert(idle.assignedUnits == frozen, "no new opportunities while disconnected")
	-- Reconnect with a paid belt: IDs continue after the last one, never repeat.
	graph = ok(graph, { op = "place", belt = belt("fix", 8, 3, "straight", 1) })
	assert(Graph.lines(layout, graph).bay_1.connected)
	local r = Ledger.advance(limits, lineConfig(graph), idle, 0.2)
	assert(#r.units == 0 or r.units[1].first == frozen + 1)
	local resumed = runFor(graph, idle, 50)
	assert(resumed.assignedUnits > frozen)
	assert(math.abs(resumed.accepted - resumed.processed - held(resumed)) < 1e-6)
end

-- 8. The catalog layout (D-024): a valid starter lane, a free second line that a
-- straight run connects, and every source's back edge against the pile.
do
	local real = defs.layout
	local fresh = Graph.new(real, rates)
	local status = Graph.lines(real, fresh)
	assert(status.bay_1.connected and #status.bay_1.belts == 7)
	assert(Graph.transportRate(status.bay_1, fresh, rates) == 1)
	assert(not status.bay_2.connected and status.bay_2.reason == "no_belt")
	local DX = { [0] = 0, [1] = 1, [2] = 0, [3] = -1 }
	local DZ = { [0] = -1, [1] = 0, [2] = 1, [3] = 0 }
	local second = real.bays[2]
	local out = second.source.outPort
	local inPort = second.processor.inPort
	local x, z = out.x + DX[out.direction], out.z + DZ[out.direction]
	local filled = fresh
	local placed = 0
	while not (x == inPort.x and z == inPort.z) do
		placed += 1
		local success, result = Graph.apply(
			real,
			rates,
			filled,
			{ op = "place", belt = belt("run" .. placed, x, z, "straight", out.direction) }
		)
		assert(success, "catalog run rejected: " .. tostring(result))
		filled = result
		x, z = x + DX[out.direction], z + DZ[out.direction]
	end
	assert(placed == 7 and Graph.lines(real, filled).bay_2.connected)
	local pile = real.pile
	local function inPile(cx: number, cz: number): boolean
		return cx >= pile.x
			and cx < pile.x + pile.width
			and cz >= pile.z
			and cz < pile.z + pile.depth
	end
	for _, bay in real.bays do
		local fp = bay.source.footprint
		local back = (bay.source.outPort.direction + 2) % 4
		for cx = fp.x, fp.x + fp.width - 1 do
			for cz = fp.z, fp.z + fp.depth - 1 do
				local nx, nz = cx + DX[back], cz + DZ[back]
				local edge = not (
					nx >= fp.x
					and nx < fp.x + fp.width
					and nz >= fp.z
					and nz < fp.z + fp.depth
				)
				assert(not edge or inPile(nx, nz), bay.id .. " source back must face the pile")
			end
		end
	end
	-- Ports sit on lane A: the cell to the flow's left (local -X) is outside the machine.
	local function outside(fp: any, cx: number, cz: number): boolean
		return cx < fp.x or cx >= fp.x + fp.width or cz < fp.z or cz >= fp.z + fp.depth
	end
	for _, bay in real.bays do
		local o, i = bay.source.outPort, bay.processor.inPort
		local left = (o.direction + 3) % 4
		assert(
			outside(bay.source.footprint, o.x + DX[left], o.z + DZ[left]),
			bay.id .. " outPort must be lane A"
		)
		assert(
			outside(bay.processor.footprint, i.x + DX[left], i.z + DZ[left]),
			bay.id .. " inPort must be lane A"
		)
	end
end

print(
	"Plot graph: starter lane, routing, invalid edits, cycles, cross-bay, move/replay, inventory-safe edits and catalog layout passed"
)
