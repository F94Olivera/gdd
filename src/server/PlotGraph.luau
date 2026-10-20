--!strict
-- Pure Ground plot conveyor graph with transactional edits (M1-03).
-- Belts carry no inventory (D-023): ordinary units live in each bay's two
-- production buffers, so placing, moving or removing a belt can only connect or
-- disconnect a line, never lose or duplicate units or discovery opportunities.
-- Layout data comes from Catalog.layout; this module requires nothing.

export type BeltKind = "straight" | "corner_left" | "corner_right"

export type Belt = {
	id: string,
	x: number,
	z: number,
	kind: BeltKind,
	-- Heading of the material leaving the belt: 0 north, 1 east, 2 south, 3 west.
	rotation: number,
	tier: string,
	-- Intel recorded at purchase; refunding it once is the economy's job (M1-08).
	paid: number,
}

export type State = {
	-- Increases on every accepted edit.
	revision: number,
	belts: { [string]: Belt },
}

export type Edit =
	{ op: "place", belt: Belt }
	| { op: "remove", id: string }
	| { op: "move", id: string, x: number, z: number, rotation: number }

export type LineStatus = {
	bay: string,
	connected: boolean,
	reason: "connected" | "no_belt" | "dangling",
	-- Belt ids from the source port onwards, in flow order.
	belts: { string },
}

type Footprint = { x: number, z: number, width: number, depth: number }
type Port = { x: number, z: number, direction: number }
type Layout = {
	gridWidth: number,
	gridDepth: number,
	blockedCells: { { x: number, z: number } },
	pile: Footprint,
	bays: {
		{
			id: string,
			source: { footprint: Footprint, outPort: Port },
			processor: { footprint: Footprint, inPort: Port },
		}
	},
	starterBeltTier: string,
	starterBelts: { { x: number, z: number, kind: string, rotation: number } },
}

local Graph = {}

local DX = { [0] = 0, [1] = 1, [2] = 0, [3] = -1 }
local DZ = { [0] = -1, [1] = 0, [2] = 1, [3] = 0 }
local KINDS = { straight = true, corner_left = true, corner_right = true }
local MAX_ID_LENGTH = 32

local function key(x: number, z: number): string
	return x .. "," .. z
end

local function isCount(value: any): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value < math.huge
		and value % 1 == 0
end

-- Heading of material arriving on the belt (before any turn).
local function inHeading(belt: Belt): number
	if belt.kind == "corner_left" then
		return (belt.rotation + 1) % 4
	elseif belt.kind == "corner_right" then
		return (belt.rotation + 3) % 4
	end
	return belt.rotation
end

type Fixed = { owner: string, kind: "pile" | "source" | "processor" | "blocked", bay: string? }

local function fixedCells(layout: Layout): { [string]: Fixed }
	local cells: { [string]: Fixed } = {}
	local function cover(footprint: Footprint, fixed: Fixed)
		for x = footprint.x, footprint.x + footprint.width - 1 do
			for z = footprint.z, footprint.z + footprint.depth - 1 do
				cells[key(x, z)] = fixed
			end
		end
	end
	for _, cell in layout.blockedCells do
		cells[key(cell.x, cell.z)] = { owner = "blocked", kind = "blocked" }
	end
	cover(layout.pile, { owner = "pile", kind = "pile" })
	for _, bay in layout.bays do
		cover(bay.source.footprint, { owner = bay.id .. ".source", kind = "source", bay = bay.id })
		cover(
			bay.processor.footprint,
			{ owner = bay.id .. ".processor", kind = "processor", bay = bay.id }
		)
	end
	return cells
end

-- Checks a whole candidate state. Returns nil when valid, else an error code.
local function check(
	layout: Layout,
	rates: { [string]: number },
	belts: { [string]: Belt }
): string?
	local fixed = fixedCells(layout)
	local byCell: { [string]: Belt } = {}
	for id, belt in belts do
		if
			type(id) ~= "string"
			or belt.id ~= id
			or #id > MAX_ID_LENGTH
			or not string.match(id, "^[a-z0-9_]+$")
		then
			return "invalid_id"
		end
		if not KINDS[belt.kind] or not isCount(belt.rotation) or belt.rotation > 3 then
			return "invalid_shape"
		end
		if type(belt.tier) ~= "string" or rates[belt.tier] == nil or not isCount(belt.paid) then
			return "invalid_tier"
		end
		if
			not isCount(belt.x)
			or not isCount(belt.z)
			or belt.x >= layout.gridWidth
			or belt.z >= layout.gridDepth
		then
			return "out_of_bounds"
		end
		local cell = key(belt.x, belt.z)
		local here = fixed[cell]
		if here then
			return if here.kind == "blocked" then "blocked" else "occupied"
		end
		if byCell[cell] then
			return "occupied"
		end
		byCell[cell] = belt
	end

	-- Every belt output must land on free space, a belt accepting from that side,
	-- or the matching processor input port.
	for _, belt in belts do
		local heading = belt.rotation
		local tx, tz = belt.x + DX[heading], belt.z + DZ[heading]
		if tx < 0 or tz < 0 or tx >= layout.gridWidth or tz >= layout.gridDepth then
			return "invalid_port"
		end
		local next = byCell[key(tx, tz)]
		local target = fixed[key(tx, tz)]
		if next then
			if inHeading(next) ~= heading then
				return "invalid_port"
			end
		elseif target then
			local accepts = false
			if target.kind == "processor" then
				for _, bay in layout.bays do
					local port = bay.processor.inPort
					if
						bay.id == target.bay
						and port.x == tx
						and port.z == tz
						and port.direction == heading
					then
						accepts = true
					end
				end
			end
			if not accepts then
				return "invalid_port"
			end
		end
	end

	-- Machine ports only connect to belts aligned with them.
	for _, bay in layout.bays do
		local out = bay.source.outPort
		local first = byCell[key(out.x + DX[out.direction], out.z + DZ[out.direction])]
		if first and inHeading(first) ~= out.direction then
			return "invalid_port"
		end
		local inPort = bay.processor.inPort
		local feeder = byCell[key(inPort.x - DX[inPort.direction], inPort.z - DZ[inPort.direction])]
		if feeder and feeder.rotation ~= inPort.direction then
			return "invalid_port"
		end
	end

	-- Each belt has one successor, so a cycle is a closed loop of belts.
	local count = 0
	for _ in belts do
		count += 1
	end
	for _, start in belts do
		local current: Belt? = start
		for _ = 1, count + 1 do
			if not current then
				break
			end
			local h = current.rotation
			current = byCell[key(current.x + DX[h], current.z + DZ[h])]
			if current == start then
				return "cycle"
			end
		end
	end

	-- M1 lines stay inside their bay: a source may only feed its own processor.
	for _, bay in layout.bays do
		local out = bay.source.outPort
		local x, z, h = out.x, out.z, out.direction
		for _ = 1, count + 1 do
			x, z = x + DX[h], z + DZ[h]
			local belt = byCell[key(x, z)]
			if not belt then
				local target = fixed[key(x, z)]
				if target and target.kind == "processor" and target.bay ~= bay.id then
					return "cross_bay"
				end
				break
			end
			h = belt.rotation
		end
	end
	return nil
end

local function copyBelts(belts: { [string]: Belt }): { [string]: Belt }
	local out = {}
	for id, belt in belts do
		out[id] = table.clone(belt)
	end
	return out
end

-- Fresh plot with the free starter connection already placed.
function Graph.new(layout: Layout, rates: { [string]: number }): State
	local belts: { [string]: Belt } = {}
	for index, starter in layout.starterBelts do
		local id = "starter_" .. index
		belts[id] = {
			id = id,
			x = starter.x,
			z = starter.z,
			kind = starter.kind :: BeltKind,
			rotation = starter.rotation,
			tier = layout.starterBeltTier,
			paid = 0,
		}
	end
	local problem = check(layout, rates, belts)
	assert(problem == nil, "starter layout invalid: " .. tostring(problem))
	return { revision = 0, belts = belts }
end

-- Applies one edit atomically. On success returns (true, newState); on failure
-- returns (false, errorCode) and the caller keeps the unchanged old state.
-- Inputs are never mutated, so a rejected or replayed edit has no effect.
function Graph.apply(
	layout: Layout,
	rates: { [string]: number },
	state: State,
	edit: Edit
): (boolean, any)
	if type(edit) ~= "table" then
		return false, "invalid_edit"
	end
	local belts = copyBelts(state.belts)
	if edit.op == "place" then
		local belt = (edit :: any).belt
		if type(belt) ~= "table" or type(belt.id) ~= "string" then
			return false, "invalid_edit"
		end
		if belts[belt.id] then
			return false, "duplicate_id"
		end
		belts[belt.id] = {
			id = belt.id,
			x = belt.x,
			z = belt.z,
			kind = belt.kind,
			rotation = belt.rotation,
			tier = belt.tier,
			paid = belt.paid,
		}
	elseif edit.op == "remove" then
		local id = (edit :: any).id
		if type(id) ~= "string" or not belts[id] then
			return false, "unknown_belt"
		end
		belts[id] = nil
	elseif edit.op == "move" then
		local e = edit :: any
		local belt = type(e.id) == "string" and belts[e.id]
		if not belt then
			return false, "unknown_belt"
		end
		belt.x, belt.z, belt.rotation = e.x, e.z, e.rotation
	else
		return false, "invalid_edit"
	end
	local problem = check(layout, rates, belts)
	if problem then
		return false, problem
	end
	return true, { revision = state.revision + 1, belts = belts }
end

-- Traces each bay from its source output port. Only a path ending at the bay's
-- own processor input port is connected; anything else is a visible inactive reason.
function Graph.lines(layout: Layout, state: State): { [string]: LineStatus }
	local byCell: { [string]: Belt } = {}
	local count = 0
	for _, belt in state.belts do
		byCell[key(belt.x, belt.z)] = belt
		count += 1
	end
	local result: { [string]: LineStatus } = {}
	for _, bay in layout.bays do
		local out = bay.source.outPort
		local inPort = bay.processor.inPort
		local x, z, h = out.x, out.z, out.direction
		local path: { string } = {}
		local connected = false
		for _ = 1, count + 1 do
			x, z = x + DX[h], z + DZ[h]
			if x == inPort.x and z == inPort.z and h == inPort.direction then
				connected = #path > 0
				break
			end
			local belt = byCell[key(x, z)]
			if not belt or inHeading(belt) ~= h then
				break
			end
			table.insert(path, belt.id)
			h = belt.rotation
		end
		result[bay.id] = {
			bay = bay.id,
			connected = connected,
			reason = if connected then "connected" elseif #path == 0 then "no_belt" else "dangling",
			belts = path,
		}
	end
	return result
end

-- Transport rate of a line: its slowest belt, or 0 while disconnected.
function Graph.transportRate(status: LineStatus, state: State, rates: { [string]: number }): number
	if not status.connected then
		return 0
	end
	local rate = math.huge
	for _, id in status.belts do
		rate = math.min(rate, rates[state.belts[id].tier])
	end
	return rate
end

return table.freeze(Graph)
