--!strict
-- Versioned public definitions for the first M1 line, permanent ranks and the
-- first promotion. Everything here replicates to clients: public values only.
-- Each value cites the producer decision (docs/DECISIONS.md) that approves it.
-- Bays and second-line bundles have no approved numbers yet; the buffer size is
-- an experimental starting value (E-017).

export type MachineKind = "extractor" | "processor" | "belt"

export type MachineTier = {
	id: string,
	-- Incremental Intel price to reach this tier from the previous one.
	price: number,
	-- Units per second; belts price and rate per segment.
	rate: number,
}

export type Machine = {
	id: string,
	kind: MachineKind,
	tiers: { MachineTier },
}

export type StarterLane = {
	id: string,
	price: number,
	clearRate: number,
	transportRate: number,
	processRate: number,
}

export type Rank = {
	id: string,
	title: string,
	minArchives: number,
}

export type Promotion = {
	id: string,
	clearanceLevel: number,
	lifetimeProcessedUnits: number,
	intelFee: number,
	requiresTutorial: boolean,
	rebuildGrant: number,
	-- Total ordinary Intel multiplier at this clearance level, not additive.
	intelMultiplier: number,
	opensSector: boolean,
}

export type Catalog = {
	schemaVersion: number,
	balanceVersion: string,
	discovery: {
		policyId: string,
		probability: number,
		guaranteeUnits: number,
	},
	throughput: {
		maxEligiblePerSecond: number,
		maxMaximumLines: number,
	},
	simulation: {
		tickHz: number,
		maxCatchUpSeconds: number,
		lineBufferUnits: number,
	},
	durability: {
		maxProvisionalUnits: number,
	},
	economy: {
		intelPerProcessedUnit: number,
	},
	starterLane: StarterLane,
	machines: { Machine },
	ranks: { Rank },
	promotions: { Promotion },
}

export type RankStanding = {
	rank: Rank,
	nextRank: Rank?,
}

local Catalog = {}

local definitions: Catalog = {
	schemaVersion = 1,
	balanceVersion = "m1-initial-1",
	-- D-011: fixed p per newly accepted eligible unit, mandatory work guarantee.
	discovery = {
		policyId = "fixed_probability_work_guarantee",
		probability = 0.00001,
		guaranteeUnits = 200000,
	},
	-- D-012: combined manual + automatic clearing cap per player/factory.
	throughput = {
		maxEligiblePerSecond = 60,
		maxMaximumLines = 2,
	},
	-- tickHz and maxCatchUpSeconds: GDD v2.0 section 1 defaults, to be measured in
	-- Studio. lineBufferUnits: experimental starting value per buffer (E-017).
	simulation = {
		tickHz = 5,
		maxCatchUpSeconds = 2,
		lineBufferUnits = 50,
	},
	-- D-017: at most 600 accepted units awaiting a durable commit.
	durability = {
		maxProvisionalUnits = 600,
	},
	economy = {
		intelPerProcessedUnit = 1,
	},
	-- GDD v2.0 section 3 and D-013: free connected lane at 1 unit/s.
	starterLane = {
		id = "starter_lane",
		price = 0,
		clearRate = 1,
		transportRate = 1,
		processRate = 1,
	},
	-- D-014 prices, D-012/D-018 rates.
	machines = {
		{
			id = "extractor",
			kind = "extractor",
			tiers = {
				{ id = "extractor_t1", price = 30, rate = 1 },
				{ id = "extractor_t2", price = 120, rate = 10 },
				{ id = "extractor_t3", price = 600, rate = 30 },
			},
		},
		{
			id = "processor",
			kind = "processor",
			tiers = {
				{ id = "processor_t1", price = 60, rate = 10 },
				{ id = "processor_t2", price = 350, rate = 40 },
			},
		},
		{
			id = "belt",
			kind = "belt",
			tiers = {
				{ id = "belt_t1", price = 5, rate = 10 },
				{ id = "belt_t2", price = 25, rate = 50 },
			},
		},
	},
	-- D-016: titles derive only from lifetime genuine archives.
	ranks = {
		{ id = "trainee", title = "Trainee", minArchives = 0 },
		{ id = "archive_finder", title = "Archive Finder", minArchives = 1 },
		{ id = "investigator", title = "Investigator", minArchives = 5 },
		{ id = "senior_investigator", title = "Senior Investigator", minArchives = 15 },
		{ id = "archive_specialist", title = "Archive Specialist", minArchives = 40 },
		{ id = "director_of_archives", title = "Director of Archives", minArchives = 100 },
	},
	-- D-014 first promotion; D-022: it opens no sector. Later promotions are unapproved.
	promotions = {
		{
			id = "clearance_1",
			clearanceLevel = 1,
			lifetimeProcessedUnits = 100000,
			intelFee = 50000,
			requiresTutorial = true,
			rebuildGrant = 100,
			intelMultiplier = 1.25,
			opensSector = false,
		},
	},
}

local MACHINE_KINDS = { extractor = true, processor = true, belt = true }

local function isFinite(value: any): boolean
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

local function isCount(value: any): boolean
	return isFinite(value) and value >= 0 and value % 1 == 0
end

local function isPositive(value: any): boolean
	return isFinite(value) and value > 0
end

-- Returns every problem found, so a bad edit reports all of them at once.
-- An empty list means the catalog is valid.
function Catalog.validate(catalog: Catalog): { string }
	local errors = {}
	local seen = {}
	local function fail(message: string)
		table.insert(errors, message)
	end
	local function claim(id: any, where: string)
		if type(id) ~= "string" or not string.match(id, "^[a-z][a-z0-9_]*$") then
			fail(where .. ": invalid id " .. tostring(id))
		elseif seen[id] then
			fail(where .. ": duplicate id " .. id)
		else
			seen[id] = true
		end
	end

	if not isCount(catalog.schemaVersion) or catalog.schemaVersion < 1 then
		fail("schemaVersion must be a positive integer")
	end
	if type(catalog.balanceVersion) ~= "string" or catalog.balanceVersion == "" then
		fail("balanceVersion must be a non-empty string")
	end

	local discovery = catalog.discovery
	claim(discovery.policyId, "discovery")
	if
		not isFinite(discovery.probability)
		or discovery.probability <= 0
		or discovery.probability >= 1
	then
		fail("discovery.probability must be in (0, 1)")
	end
	if not isCount(discovery.guaranteeUnits) or discovery.guaranteeUnits < 1 then
		fail("discovery.guaranteeUnits must be a positive integer")
	end

	local throughput = catalog.throughput
	if not isPositive(throughput.maxEligiblePerSecond) then
		fail("throughput.maxEligiblePerSecond must be positive")
	end
	if not isCount(throughput.maxMaximumLines) or throughput.maxMaximumLines < 1 then
		fail("throughput.maxMaximumLines must be a positive integer")
	end
	if not isPositive(catalog.simulation.tickHz) then
		fail("simulation.tickHz must be positive")
	end
	if not isPositive(catalog.simulation.maxCatchUpSeconds) then
		fail("simulation.maxCatchUpSeconds must be positive")
	end
	if
		not isCount(catalog.simulation.lineBufferUnits)
		or catalog.simulation.lineBufferUnits < 1
	then
		fail("simulation.lineBufferUnits must be a positive integer")
	end
	if
		not isCount(catalog.durability.maxProvisionalUnits)
		or catalog.durability.maxProvisionalUnits < 1
	then
		fail("durability.maxProvisionalUnits must be a positive integer")
	end
	if not isPositive(catalog.economy.intelPerProcessedUnit) then
		fail("economy.intelPerProcessedUnit must be positive")
	end

	local starter = catalog.starterLane
	claim(starter.id, "starterLane")
	if not isCount(starter.price) then
		fail("starterLane.price must be a non-negative integer")
	end
	for _, field in { "clearRate", "transportRate", "processRate" } do
		if not isPositive((starter :: any)[field]) then
			fail("starterLane." .. field .. " must be positive")
		end
	end

	local maxExtractorRate = 0
	for index, machine in catalog.machines do
		local where = "machines[" .. index .. "]"
		claim(machine.id, where)
		if not MACHINE_KINDS[machine.kind] then
			fail(where .. ": unknown kind " .. tostring(machine.kind))
		end
		if #machine.tiers == 0 then
			fail(where .. ": needs at least one tier")
		end
		local previousRate = 0
		for tierIndex, tier in machine.tiers do
			local tierWhere = where .. ".tiers[" .. tierIndex .. "]"
			claim(tier.id, tierWhere)
			if not isCount(tier.price) then
				fail(tierWhere .. ": price must be a non-negative integer")
			end
			if not isPositive(tier.rate) then
				fail(tierWhere .. ": rate must be positive")
			elseif tier.rate <= previousRate then
				fail(tierWhere .. ": rate must increase over the previous tier")
			else
				previousRate = tier.rate
			end
		end
		if machine.kind == "extractor" then
			maxExtractorRate = math.max(maxExtractorRate, previousRate)
		end
	end
	-- D-012: the approved number of maximum lines must fit inside the global cap.
	if
		isPositive(throughput.maxEligiblePerSecond)
		and maxExtractorRate * throughput.maxMaximumLines > throughput.maxEligiblePerSecond
	then
		fail("maximum extractor lines exceed throughput.maxEligiblePerSecond")
	end

	-- One tick must be able to move a full tier's worth through each buffer;
	-- otherwise the discrete step, not the machine, caps throughput at buffer * tickHz.
	if isPositive(catalog.simulation.tickHz) and isPositive(catalog.simulation.lineBufferUnits) then
		local perTick = catalog.simulation.lineBufferUnits * catalog.simulation.tickHz
		for _, machine in catalog.machines do
			for _, tier in machine.tiers do
				if isPositive(tier.rate) and tier.rate > perTick then
					fail(tier.id .. ": rate exceeds lineBufferUnits * tickHz")
				end
			end
		end
	end

	if #catalog.ranks == 0 or catalog.ranks[1].minArchives ~= 0 then
		fail("ranks must start at minArchives 0")
	end
	local previousMin = -1
	for index, rank in catalog.ranks do
		local where = "ranks[" .. index .. "]"
		claim(rank.id, where)
		if type(rank.title) ~= "string" or rank.title == "" then
			fail(where .. ": title must be a non-empty string")
		end
		if not isCount(rank.minArchives) then
			fail(where .. ": minArchives must be a non-negative integer")
		elseif rank.minArchives <= previousMin then
			fail(where .. ": minArchives must be strictly ascending")
		else
			previousMin = rank.minArchives
		end
	end

	for index, promotion in catalog.promotions do
		local where = "promotions[" .. index .. "]"
		claim(promotion.id, where)
		if promotion.clearanceLevel ~= index then
			fail(where .. ": clearanceLevel must be " .. index)
		end
		if
			not isCount(promotion.lifetimeProcessedUnits)
			or promotion.lifetimeProcessedUnits < 1
		then
			fail(where .. ": lifetimeProcessedUnits must be a positive integer")
		end
		if not isCount(promotion.intelFee) then
			fail(where .. ": intelFee must be a non-negative integer")
		end
		if not isCount(promotion.rebuildGrant) then
			fail(where .. ": rebuildGrant must be a non-negative integer")
		end
		if not isFinite(promotion.intelMultiplier) or promotion.intelMultiplier < 1 then
			fail(where .. ": intelMultiplier must be at least 1")
		end
		if
			type(promotion.requiresTutorial) ~= "boolean"
			or type(promotion.opensSector) ~= "boolean"
		then
			fail(where .. ": requiresTutorial and opensSector must be booleans")
		end
	end

	return errors
end

-- Shared budget limits for the server production ledger (M1-02), derived from
-- the catalog so they cannot drift from the approved values.
function Catalog.productionLimits(catalog: Catalog): {
	maxEligiblePerSecond: number,
	maxMaximumLines: number,
	maximumLineRate: number,
	tickSeconds: number,
	maxCatchUpSeconds: number,
	maxProvisionalUnits: number,
}
	local maximumLineRate = 0
	for _, machine in catalog.machines do
		if machine.kind == "extractor" then
			maximumLineRate = math.max(maximumLineRate, machine.tiers[#machine.tiers].rate)
		end
	end
	return {
		maxEligiblePerSecond = catalog.throughput.maxEligiblePerSecond,
		maxMaximumLines = catalog.throughput.maxMaximumLines,
		maximumLineRate = maximumLineRate,
		tickSeconds = 1 / catalog.simulation.tickHz,
		maxCatchUpSeconds = catalog.simulation.maxCatchUpSeconds,
		maxProvisionalUnits = catalog.durability.maxProvisionalUnits,
	}
end

-- Permanent title for a lifetime genuine archive count. Counts above the last
-- threshold keep the last title; there is no collectible cap.
function Catalog.rankFor(catalog: Catalog, lifetimeArchives: number): RankStanding
	assert(isCount(lifetimeArchives), "lifetimeArchives must be a non-negative integer")
	local ranks = catalog.ranks
	local current = 1
	for index, rank in ranks do
		if lifetimeArchives >= rank.minArchives then
			current = index
		end
	end
	return { rank = ranks[current], nextRank = ranks[current + 1] }
end

local function deepFreeze(value: any): any
	if type(value) == "table" and not table.isfrozen(value) then
		for _, child in value do
			deepFreeze(child)
		end
		table.freeze(value)
	end
	return value
end

local invalid = Catalog.validate(definitions)
assert(#invalid == 0, "invalid catalog definitions: " .. table.concat(invalid, "; "))
Catalog.definitions = deepFreeze(definitions) :: Catalog

return table.freeze(Catalog)
