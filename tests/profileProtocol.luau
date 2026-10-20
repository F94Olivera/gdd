--!strict
-- M1-04: D-017 save protocol against a deterministic fake store with injected
-- failures (TEST_PLAN P-001 to P-010 where they apply without real services).
local P = require("../src/server/ProfileProtocol")
local Catalog = require("../src/shared/Catalog")
local durability = Catalog.definitions.durability
local LEASE = durability.leaseSeconds
local OUTBOX = durability.outboxLimit

local function deepCopy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in value do
		out[k] = deepCopy(v)
	end
	return out
end

-- Fake DataStore key. faults is a queue consumed one per call:
-- "fail_before" (nothing written), "fail_after" (written, response lost),
-- "race" (another writer's transform runs first, then ours is re-run like
-- UpdateAsync does on conflict), "read_fail".
type Fake = {
	value: any,
	writes: number,
	transformCalls: number,
	faults: { any },
	store: P.Store,
}
local function fake(initial: any?): Fake
	local self: Fake = {
		value = deepCopy(initial),
		writes = 0,
		transformCalls = 0,
		faults = {},
		store = nil :: any,
	}
	local function nextFault(): any
		return table.remove(self.faults, 1)
	end
	self.store = {
		update = function(transform)
			local fault = nextFault()
			if fault == "fail_before" then
				return false, "transient"
			end
			if type(fault) == "table" and fault.race then
				-- Our transform sees the old value first, then the race wins and ours re-runs.
				self.transformCalls += 1
				transform(deepCopy(self.value))
				local raced = fault.race(deepCopy(self.value))
				if raced ~= nil then
					self.value = deepCopy(raced)
					self.writes += 1
				end
			end
			self.transformCalls += 1
			local result = transform(deepCopy(self.value))
			if result ~= nil then
				self.value = deepCopy(result)
				self.writes += 1
			end
			if fault == "fail_after" then
				return false, "response lost"
			end
			return true, deepCopy(self.value)
		end,
		read = function()
			if nextFault() == "read_fail" then
				return false, nil
			end
			return true, deepCopy(self.value)
		end,
	}
	return self
end

local function acquire(f: Fake, token: string, now: number): string
	local outcome = "unknown"
	local ok = f.store.update(function(stored)
		local record, result = P.acquire(
			stored,
			{ token = token, generation = "gen_a", now = now, leaseSeconds = LEASE }
		)
		outcome = result
		return record
	end)
	return if ok then outcome else "failed"
end

local function mutation(f: Fake, token: string, id: string, data: P.Data, now: number): P.Mutation
	local record = f.value :: P.Record
	return {
		token = token,
		epoch = (record.session :: P.Session).epoch,
		generation = record.generation,
		expectedSeq = record.commitSeq,
		mutationId = id,
		data = data,
		now = now,
		leaseSeconds = LEASE,
	}
end

-- P-001: failed loads and malformed or future records never yield a blank playable profile.
do
	local f = fake(nil)
	table.insert(f.faults, "fail_before")
	assert(acquire(f, "server_1", 0) == "failed" and f.value == nil and f.writes == 0)
	assert(acquire(f, "server_1", 0) == "created" and f.writes == 1)
	assert(acquire(f, "server_2", 1) == "locked", "a second creation must not overwrite")
	for _, bad in
		{
			{
				schemaVersion = 2,
				generation = "gen_a",
				commitSeq = 0,
				lastMutationId = "",
				data = P.newData(),
			},
			{ schemaVersion = 1, generation = "gen_a", commitSeq = 0, lastMutationId = "" },
			"corrupted",
			{
				schemaVersion = 1,
				generation = "gen_a",
				commitSeq = -1,
				lastMutationId = "",
				data = P.newData(),
			},
		}
	do
		local g = fake(bad)
		assert(acquire(g, "server_1", 0) == "invalid")
		assert(g.writes == 0, "malformed record was overwritten")
	end
	local nan = P.newData()
	nan.intel = 0 / 0
	assert(P.checkData(nan) ~= nil)
end

-- P-002: one owner; an expired lease moves to a new epoch and the old owner is fenced,
-- even if its own clock still believes the lease is valid.
do
	local f = fake(nil)
	assert(acquire(f, "server_1", 0) == "created")
	local old = mutation(f, "server_1", "m1", P.recordUnits(P.newData(), 10, 0), 5)
	assert(acquire(f, "server_2", 60) == "locked")
	assert(acquire(f, "server_2", LEASE + 1) == "acquired")
	assert((f.value :: P.Record).session.epoch == 2)
	-- server_1 still thinks it is time 5 (skewed); its token/epoch no longer match.
	assert(P.save(f.store, old, 3) == "fenced")
	assert((f.value :: P.Record).data.eligibleCursor == 0)
	-- The owner can renew its own lease.
	assert(acquire(f, "server_2", LEASE + 2) == "renewed")
	-- Release keeps data and lets the next server in immediately.
	local ok = f.store.update(function(stored)
		return (P.release(stored, "server_2", 2))
	end)
	assert(ok and (f.value :: P.Record).session == nil)
	assert(acquire(f, "server_3", LEASE + 3) == "acquired")
end

-- P-003: the commit transform is deterministic, re-runs safely and rejects a moved sequence.
do
	local f = fake(nil)
	acquire(f, "server_1", 0)
	local m = mutation(f, "server_1", "m1", P.recordUnits(P.newData(), 100, 0.5), 1)
	local a = { P.commit(deepCopy(f.value), m) }
	local b = { P.commit(deepCopy(f.value), m) }
	assert(a[2] == "committed" and b[2] == "committed")
	assert(
		a[1].commitSeq == b[1].commitSeq and a[1].data.eligibleCursor == b[1].data.eligibleCursor
	)
	assert(f.value.commitSeq == 0, "transform mutated its input")
	-- Another commit by the same session lands first: ours re-runs and reports a conflict.
	local other = mutation(f, "server_1", "other", P.recordUnits(P.newData(), 50, 0), 1)
	table.insert(f.faults, {
		race = function(stored)
			return (P.commit(stored, other))
		end,
	})
	assert(P.save(f.store, m, 1) == "conflict")
	assert(f.value.lastMutationId == "other" and f.value.data.eligibleCursor == 50)
	-- A candidate that lowers a permanent counter is refused.
	local lower = mutation(f, "server_1", "lower", P.recordUnits(P.newData(), 10, 0), 2)
	assert(P.save(f.store, lower, 1) == "regression")
end

-- P-004 / P-005: an award commit either happens once or not at all, never twice,
-- including when the write lands but the response is lost.
do
	for _, scenario in { "fail_before", "fail_after", "clean" } do
		local f = fake(nil)
		acquire(f, "server_1", 0)
		local base = f.value.data :: P.Data
		local awarded = assert(P.award(P.recordUnits(base, 41, 0), "gen_a", 42, OUTBOX))
		-- Ordinary output of the found unit stays payable: processing is recorded separately.
		awarded.processedLifetime += 1
		awarded.intel += 1
		local m = mutation(f, "server_1", "find_42", awarded, 1)
		if scenario ~= "clean" then
			table.insert(f.faults, scenario)
		end
		-- One attempt: a crash right here leaves either the base or base + 1.
		local first = P.save(f.store, m, 1)
		local stored = f.value.data :: P.Data
		if scenario == "fail_before" then
			assert(first == "pending" or first == "confirmed")
			assert(stored.lifetimeArchives == 0)
		else
			assert(first == "confirmed" and stored.lifetimeArchives == 1)
		end
		-- Retrying the same immutable candidate converges to exactly +1.
		assert(P.save(f.store, m, 3) == "confirmed")
		stored = f.value.data :: P.Data
		assert(stored.lifetimeArchives == 1 and stored.discoveryFailures == 0)
		assert(#stored.outbox == 1 and stored.outbox[1].awardId == "gen_a:42")
		assert(stored.processedLifetime == 1 and f.value.commitSeq == 1)
	end
	-- Unknown write and a failed reconciliation read stay "pending", never "confirmed".
	local f = fake(nil)
	acquire(f, "server_1", 0)
	local m = mutation(f, "server_1", "m1", P.recordUnits(P.newData(), 5, 0), 1)
	f.faults = { "fail_before", "read_fail", "fail_before", "read_fail" }
	assert(P.save(f.store, m, 2) == "pending")
end

-- P-007: rejoin keeps cursor, fraction, failures and count; no reroll of old IDs.
do
	local f = fake(nil)
	acquire(f, "server_1", 0)
	local data = P.recordUnits(P.newData(), 1234, 0.75)
	assert(P.save(f.store, mutation(f, "server_1", "m1", data, 1), 1) == "confirmed")
	assert(acquire(f, "server_2", LEASE + 10) == "acquired")
	local loaded = f.value.data :: P.Data
	assert(
		loaded.eligibleCursor == 1234
			and loaded.acceptedFraction == 0.75
			and loaded.discoveryFailures == 1234
	)
	assert(P.award(loaded, "gen_a", 1234, OUTBOX) == nil, "an evaluated unit was re-rolled")
	assert(select(2, P.award(loaded, "gen_a", 1000, OUTBOX)) == "already_evaluated")
end

-- P-008: an unpresented award survives rejoin; ack removes it once; a lost ack
-- replays harmlessly; after removal the cursor still blocks a second grant.
do
	local f = fake(nil)
	acquire(f, "server_1", 0)
	local awarded = assert(P.award(P.newData(), "gen_a", 7, OUTBOX))
	assert(P.save(f.store, mutation(f, "server_1", "find_7", awarded, 1), 1) == "confirmed")
	assert(acquire(f, "server_2", LEASE + 1) == "acquired")
	local loaded = f.value.data :: P.Data
	assert(#loaded.outbox == 1 and loaded.outbox[1].awardId == "gen_a:7")
	local acked = P.acknowledge(loaded, "gen_a:7")
	local m = mutation(f, "server_2", "ack_7", acked, LEASE + 2)
	table.insert(f.faults, "fail_after")
	assert(P.save(f.store, m, 2) == "confirmed")
	local after = f.value.data :: P.Data
	assert(#after.outbox == 0 and after.lifetimeArchives == 1)
	assert(#P.acknowledge(after, "gen_a:7").outbox == 0)
	assert(P.award(after, "gen_a", 7, OUTBOX) == nil, "re-granted after the outbox forgot it")
end

-- P-009: a full outbox pauses new awards instead of dropping one.
do
	local data = P.newData()
	for unit = 1, OUTBOX do
		data = assert(P.award(data, "gen_a", unit * 10, OUTBOX))
	end
	assert(#data.outbox == OUTBOX and data.lifetimeArchives == OUTBOX)
	local blocked, reason = P.award(data, "gen_a", OUTBOX * 10 + 1, OUTBOX)
	assert(blocked == nil and reason == "outbox_full")
	assert(#data.outbox == OUTBOX, "an entry was dropped")
	local freed = P.acknowledge(data, "gen_a:10")
	assert(P.award(freed, "gen_a", OUTBOX * 10 + 1, OUTBOX) ~= nil)
end

-- P-010: a replayed or stale command is rejected by the durable high-water mark.
do
	local data = assert(P.acceptCommand(P.newData(), 1))
	data = assert(P.acceptCommand(data, 5))
	assert(select(2, P.acceptCommand(data, 5)) == "replayed")
	assert(select(2, P.acceptCommand(data, 2)) == "replayed")
	assert(select(2, P.acceptCommand(data, 0 / 0)) == "replayed")
	assert(P.acceptCommand(data, 6) ~= nil)
end

-- Helpers never mutate their input and keep the cursor monotonic.
do
	local data = P.recordUnits(P.newData(), 10, 0.2)
	local before = data.eligibleCursor
	P.recordUnits(data, 20, 0.3)
	assert(data.eligibleCursor == before)
	assert(not pcall(P.recordUnits, data, 9, 0))
	assert(not pcall(P.recordUnits, data, 11, 1))
end

print(
	"Profile protocol: load/lease/fence, deterministic CAS, exactly-once award, reconcile, rejoin, outbox, replay passed (P-001 to P-005, P-007 to P-010)"
)
