--!strict
-- Pure D-017 save protocol (M1-04): session lease and fencing, sequenced
-- immutable commits, reconciliation after lost responses, the award outbox and
-- command replay protection. No Roblox services: the transforms below are meant
-- to run inside UpdateAsync, so they never yield, emit events or use RNG, and
-- return the same candidate when called again with the same stored value.
-- A record is durable only when the store confirms it (ARCHITECTURE, D-017).

export type Session = { token: string, epoch: number, leaseUntil: number }

export type OutboxEntry = { awardId: string, unitId: number }

export type Data = {
	-- Highest eligible unit ID whose discovery opportunity is durably evaluated.
	eligibleCursor: number,
	-- Accepted work beyond the cursor that has not become a whole unit, in [0, 1).
	acceptedFraction: number,
	discoveryFailures: number,
	lifetimeArchives: number,
	intel: number,
	processedLifetime: number,
	-- Genuine awards committed but not yet acknowledged as presented.
	outbox: { OutboxEntry },
	-- Highest purchase/promotion command sequence already applied.
	commandHighWater: number,
}

export type Record = {
	schemaVersion: number,
	-- Immutable identity of this profile; award IDs are generation:unitId.
	generation: string,
	session: Session?,
	commitSeq: number,
	lastMutationId: string,
	data: Data,
}

export type AcquireRequest = {
	token: string,
	generation: string,
	now: number,
	leaseSeconds: number,
}

export type Mutation = {
	token: string,
	epoch: number,
	generation: string,
	-- commitSeq the writer last saw; the commit becomes expectedSeq + 1.
	expectedSeq: number,
	mutationId: string,
	data: Data,
	now: number,
	leaseSeconds: number,
}

-- update(transform) runs transform on the stored value and writes a non-nil
-- result, returning false when the outcome is unknown or failed. read() must
-- bypass caches. Both match the shape of DataStore UpdateAsync/GetAsync.
export type Store = {
	update: (transform: (any) -> any) -> (boolean, any),
	read: () -> (boolean, any),
}

local Protocol = {}

Protocol.SCHEMA_VERSION = 1

local function isCount(value: any): boolean
	return type(value) == "number"
		and value == value
		and value >= 0
		and value < math.huge
		and value % 1 == 0
end

local function isFinite(value: any): boolean
	return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function isText(value: any): boolean
	return type(value) == "string" and value ~= "" and #value <= 64
end

local function copyData(data: Data): Data
	local outbox = {}
	for index, entry in data.outbox do
		outbox[index] = { awardId = entry.awardId, unitId = entry.unitId }
	end
	return {
		eligibleCursor = data.eligibleCursor,
		acceptedFraction = data.acceptedFraction,
		discoveryFailures = data.discoveryFailures,
		lifetimeArchives = data.lifetimeArchives,
		intel = data.intel,
		processedLifetime = data.processedLifetime,
		outbox = outbox,
		commandHighWater = data.commandHighWater,
	}
end

local function copyRecord(record: Record): Record
	local session = record.session
	return {
		schemaVersion = record.schemaVersion,
		generation = record.generation,
		session = if session
			then { token = session.token, epoch = session.epoch, leaseUntil = session.leaseUntil }
			else nil,
		commitSeq = record.commitSeq,
		lastMutationId = record.lastMutationId,
		data = copyData(record.data),
	}
end

function Protocol.newData(): Data
	return {
		eligibleCursor = 0,
		acceptedFraction = 0,
		discoveryFailures = 0,
		lifetimeArchives = 0,
		intel = 0,
		processedLifetime = 0,
		outbox = {},
		commandHighWater = 0,
	}
end

-- Structural check of profile data. Returns nil when valid, else a reason.
function Protocol.checkData(data: any): string?
	if type(data) ~= "table" then
		return "data missing"
	end
	for _, field in
		{
			"eligibleCursor",
			"discoveryFailures",
			"lifetimeArchives",
			"intel",
			"processedLifetime",
			"commandHighWater",
		}
	do
		if not isCount(data[field]) then
			return field .. " must be a non-negative integer"
		end
	end
	if
		not isFinite(data.acceptedFraction)
		or data.acceptedFraction < 0
		or data.acceptedFraction >= 1
	then
		return "acceptedFraction must be in [0, 1)"
	end
	if type(data.outbox) ~= "table" then
		return "outbox missing"
	end
	local seen = {}
	for index, entry in data.outbox do
		if
			type(index) ~= "number"
			or type(entry) ~= "table"
			or not isText(entry.awardId)
			or not isCount(entry.unitId)
		then
			return "outbox entry malformed"
		end
		if seen[entry.awardId] or entry.unitId > data.eligibleCursor then
			return "outbox entry duplicated or ahead of cursor"
		end
		seen[entry.awardId] = true
	end
	if #data.outbox > data.lifetimeArchives then
		return "outbox larger than lifetime archives"
	end
	return nil
end

-- Full record check. Unknown future schemas are rejected, never rewritten.
function Protocol.checkRecord(value: any): string?
	if type(value) ~= "table" then
		return "record is not a table"
	end
	if value.schemaVersion ~= Protocol.SCHEMA_VERSION then
		return "unsupported schemaVersion " .. tostring(value.schemaVersion)
	end
	if
		not isText(value.generation)
		or not isCount(value.commitSeq)
		or type(value.lastMutationId) ~= "string"
	then
		return "record header malformed"
	end
	local session = value.session
	if session ~= nil then
		if
			type(session) ~= "table"
			or not isText(session.token)
			or not isCount(session.epoch)
			or not isFinite(session.leaseUntil)
		then
			return "session malformed"
		end
	end
	return Protocol.checkData(value.data)
end

-- UpdateAsync transform to load and own a profile. Creates one only when the
-- stored value is genuinely nil; malformed or future records stay untouched.
-- Returns (record to write or nil, outcome).
function Protocol.acquire(stored: any, request: AcquireRequest): (Record?, string)
	assert(
		isText(request.token) and isText(request.generation),
		"acquire needs token and generation"
	)
	assert(isFinite(request.now) and isCount(request.leaseSeconds), "acquire needs now and lease")
	local leaseUntil = request.now + request.leaseSeconds
	if stored == nil then
		return {
			schemaVersion = Protocol.SCHEMA_VERSION,
			generation = request.generation,
			session = { token = request.token, epoch = 1, leaseUntil = leaseUntil },
			commitSeq = 0,
			lastMutationId = "",
			data = Protocol.newData(),
		},
			"created"
	end
	if Protocol.checkRecord(stored) then
		return nil, "invalid"
	end
	local record = copyRecord(stored)
	local session = record.session
	if session and session.token == request.token then
		session.leaseUntil = leaseUntil
		return record, "renewed"
	end
	if session and session.leaseUntil > request.now then
		return nil, "locked"
	end
	record.session = {
		token = request.token,
		epoch = (if session then session.epoch else 0) + 1,
		leaseUntil = leaseUntil,
	}
	return record, "acquired"
end

-- Whether stored already holds exactly this mutation.
local function holds(stored: Record, mutation: Mutation): boolean
	return stored.generation == mutation.generation
		and stored.lastMutationId == mutation.mutationId
		and stored.commitSeq == mutation.expectedSeq + 1
end

-- Fields that may never go down between commits.
local function regresses(old: Data, new: Data): boolean
	return new.eligibleCursor < old.eligibleCursor
		or new.lifetimeArchives < old.lifetimeArchives
		or new.processedLifetime < old.processedLifetime
		or new.commandHighWater < old.commandHighWater
end

-- UpdateAsync transform for one sequenced commit. Outcomes: "committed" (write
-- the returned record), "already" (this exact mutation is stored; no write),
-- "fenced" (lease or session lost), "conflict" (sequence moved), "invalid",
-- "regression" (candidate would lower a permanent counter).
function Protocol.commit(stored: any, mutation: Mutation): (Record?, string)
	if Protocol.checkRecord(stored) or Protocol.checkData(mutation.data) then
		return nil, "invalid"
	end
	if holds(stored, mutation) then
		return nil, "already"
	end
	local session = stored.session
	if
		stored.generation ~= mutation.generation
		or not session
		or session.token ~= mutation.token
		or session.epoch ~= mutation.epoch
		or session.leaseUntil <= mutation.now
	then
		return nil, "fenced"
	end
	if stored.commitSeq ~= mutation.expectedSeq then
		return nil, "conflict"
	end
	if regresses(stored.data, mutation.data) then
		return nil, "regression"
	end
	local record = copyRecord(stored)
	record.commitSeq += 1
	record.lastMutationId = mutation.mutationId
	record.data = copyData(mutation.data)
	local nextSession = record.session :: Session
	nextSession.leaseUntil = mutation.now + mutation.leaseSeconds
	return record, "committed"
end

-- UpdateAsync transform that gives up the lease, keeping the data.
function Protocol.release(stored: any, token: string, epoch: number): (Record?, string)
	if Protocol.checkRecord(stored) then
		return nil, "invalid"
	end
	local session = stored.session
	if not session or session.token ~= token or session.epoch ~= epoch then
		return nil, "fenced"
	end
	local record = copyRecord(stored)
	record.session = nil
	return record, "released"
end

-- After an unknown write result, decide from an uncached read: "confirmed" when
-- the mutation is stored, "retry" when the store still holds the previous
-- commit under our session, "lost" otherwise (stop and reload with authority).
function Protocol.reconcile(stored: any, mutation: Mutation): string
	if Protocol.checkRecord(stored) then
		return "lost"
	end
	if holds(stored, mutation) then
		return "confirmed"
	end
	local session = stored.session
	if
		stored.generation == mutation.generation
		and stored.commitSeq == mutation.expectedSeq
		and session
		and session.token == mutation.token
		and session.epoch == mutation.epoch
	then
		return "retry"
	end
	return "lost"
end

-- Writes one immutable candidate, reconciling after failures. Returns
-- "confirmed", "pending" (still unknown after maxAttempts; keep the profile
-- non-playable and retry later), or the terminal outcome ("fenced", "conflict",
-- "invalid", "regression", "lost"). Backoff between attempts is the caller's.
function Protocol.save(store: Store, mutation: Mutation, maxAttempts: number): string
	assert(isCount(maxAttempts) and maxAttempts >= 1, "maxAttempts must be a positive integer")
	for _ = 1, maxAttempts do
		local outcome = "unknown"
		local ok = store.update(function(stored)
			local record, result = Protocol.commit(stored, mutation)
			outcome = result
			return record
		end)
		if ok then
			if outcome == "committed" or outcome == "already" then
				return "confirmed"
			end
			return outcome
		end
		local readOk, stored = store.read()
		if readOk then
			local state = Protocol.reconcile(stored, mutation)
			if state ~= "retry" then
				return state
			end
		end
	end
	return "pending"
end

-- New data recording that units after the cursor through throughUnit were
-- evaluated without a find. Never moves the cursor backwards.
function Protocol.recordUnits(data: Data, throughUnit: number, fraction: number): Data
	assert(
		isCount(throughUnit) and throughUnit >= data.eligibleCursor,
		"cursor cannot move backwards"
	)
	assert(isFinite(fraction) and fraction >= 0 and fraction < 1, "fraction must be in [0, 1)")
	local next = copyData(data)
	next.discoveryFailures += throughUnit - data.eligibleCursor
	next.eligibleCursor = throughUnit
	next.acceptedFraction = fraction
	return next
end

-- New data with one genuine award at unitId: exactly +1 lifetime, failures reset,
-- cursor at the unit and an outbox entry. Returns (nil, reason) for a unit at or
-- below the cursor (already evaluated, even after its outbox entry is gone) or
-- when the outbox is full, which must pause clearing rather than drop an award.
function Protocol.award(
	data: Data,
	generation: string,
	unitId: number,
	outboxLimit: number
): (Data?, string)
	assert(isText(generation) and isCount(outboxLimit), "award needs generation and limit")
	if not isCount(unitId) or unitId <= data.eligibleCursor then
		return nil, "already_evaluated"
	end
	if #data.outbox >= outboxLimit then
		return nil, "outbox_full"
	end
	local next = copyData(data)
	next.eligibleCursor = unitId
	next.discoveryFailures = 0
	next.lifetimeArchives += 1
	table.insert(next.outbox, { awardId = generation .. ":" .. unitId, unitId = unitId })
	return next, "awarded"
end

-- New data without the presented award. Acknowledging twice is harmless and
-- never changes lifetime archives.
function Protocol.acknowledge(data: Data, awardId: string): Data
	local next = copyData(data)
	for index, entry in next.outbox do
		if entry.awardId == awardId then
			table.remove(next.outbox, index)
			break
		end
	end
	return next
end

-- New data after accepting a purchase/promotion command. Replays and stale
-- sequences are rejected by the durable high-water mark, not by a history list.
function Protocol.acceptCommand(data: Data, commandSeq: number): (Data?, string)
	if not isCount(commandSeq) or commandSeq <= data.commandHighWater then
		return nil, "replayed"
	end
	local next = copyData(data)
	next.commandHighWater = commandSeq
	return next, "accepted"
end

return table.freeze(Protocol)
