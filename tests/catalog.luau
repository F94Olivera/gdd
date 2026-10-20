--!strict
-- M1-01: versioned public catalog values, validation and rank boundaries.
local Catalog = require("../src/shared/Catalog")
local defs = Catalog.definitions

local function copy(value: any): any
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for key, child in value do
		out[key] = copy(child)
	end
	return out
end

local function tier(machineId: string, tierId: string): any
	for _, machine in defs.machines do
		if machine.id == machineId then
			for _, t in machine.tiers do
				if t.id == tierId then
					return t
				end
			end
		end
	end
	error("missing tier " .. tierId)
end

-- Approved values are traced to their decisions.
assert(#Catalog.validate(defs) == 0)
assert(defs.discovery.probability == 0.00001 and defs.discovery.guaranteeUnits == 200000) -- D-011
assert(defs.throughput.maxEligiblePerSecond == 60 and defs.throughput.maxMaximumLines == 2) -- D-012
local starter = defs.starterLane
assert(
	starter.price == 0
		and starter.clearRate == 1
		and starter.transportRate == 1
		and starter.processRate == 1
)
local expected = {
	{ "extractor", "extractor_t1", 30, 1 },
	{ "extractor", "extractor_t2", 120, 10 },
	{ "extractor", "extractor_t3", 600, 30 },
	{ "processor", "processor_t1", 60, 10 },
	{ "processor", "processor_t2", 350, 40 },
	{ "belt", "belt_t1", 5, 10 },
	{ "belt", "belt_t2", 25, 50 },
}
local tiers = 0
for _, machine in defs.machines do
	tiers += #machine.tiers
end
assert(tiers == #expected, "unexpected extra tiers")
for _, row in expected do
	local t = tier(row[1], row[2])
	assert(t.price == row[3] and t.rate == row[4], row[2])
end
assert(defs.economy.intelPerProcessedUnit == 1)
assert(#defs.promotions == 1, "only the first promotion is approved for M1")
local first = defs.promotions[1]
assert(first.lifetimeProcessedUnits == 100000 and first.intelFee == 50000) -- D-014
assert(first.rebuildGrant == 100 and first.intelMultiplier == 1.25 and first.requiresTutorial)
assert(first.opensSector == false) -- D-022

-- Definitions are frozen at every depth.
for _, attempt in
	{
		function()
			(defs :: any).schemaVersion = 2
		end,
		function()
			(defs.discovery :: any).probability = 1
		end,
		function()
			(defs.machines[1].tiers[1] :: any).price = 0
		end,
		function()
			(Catalog :: any).definitions = {}
		end,
	}
do
	assert(not pcall(attempt), "catalog must be immutable")
end

-- D-016 rank boundaries, including counts above the last title.
local boundaries = {
	{ 0, "trainee", "archive_finder" },
	{ 1, "archive_finder", "investigator" },
	{ 4, "archive_finder", "investigator" },
	{ 5, "investigator", "senior_investigator" },
	{ 14, "investigator", "senior_investigator" },
	{ 15, "senior_investigator", "archive_specialist" },
	{ 39, "senior_investigator", "archive_specialist" },
	{ 40, "archive_specialist", "director_of_archives" },
	{ 99, "archive_specialist", "director_of_archives" },
	{ 100, "director_of_archives", nil },
	{ 1000000, "director_of_archives", nil },
}
for _, row in boundaries do
	local standing = Catalog.rankFor(defs, row[1] :: number)
	assert(standing.rank.id == row[2], "rank at " .. row[1])
	assert((standing.nextRank and standing.nextRank.id) == row[3], "next rank at " .. row[1])
end
assert(Catalog.rankFor(defs, 0).rank.title == "Trainee")
assert(Catalog.rankFor(defs, 100).rank.title == "Director of Archives")
for _, bad in { -1, 0.5, 0 / 0, math.huge, -math.huge } do
	assert(not pcall(Catalog.rankFor, defs, bad), "rankFor must reject " .. tostring(bad))
end
assert(not pcall(Catalog.rankFor, defs, "5" :: any))

-- Each broken definition is rejected with a message naming the problem.
local cases: { { message: string, mutate: (any) -> () } } = {
	{
		message = "duplicate id",
		mutate = function(c)
			c.machines[2].tiers[1].id = "extractor_t1"
		end,
	},
	{
		message = "invalid id",
		mutate = function(c)
			c.machines[1].id = "Extractor"
		end,
	},
	{
		message = "unknown kind",
		mutate = function(c)
			c.machines[1].kind = "splitter"
		end,
	},
	{
		message = "price must be",
		mutate = function(c)
			c.machines[1].tiers[1].price = -30
		end,
	},
	{
		message = "price must be",
		mutate = function(c)
			c.machines[3].tiers[1].price = 5.5
		end,
	},
	{
		message = "rate must be positive",
		mutate = function(c)
			c.machines[2].tiers[1].rate = 0 / 0
		end,
	},
	{
		message = "rate must increase",
		mutate = function(c)
			c.machines[1].tiers[2].rate = 1
		end,
	},
	{
		message = "needs at least one tier",
		mutate = function(c)
			c.machines[3].tiers = {}
		end,
	},
	{
		message = "discovery.probability",
		mutate = function(c)
			c.discovery.probability = 0
		end,
	},
	{
		message = "discovery.probability",
		mutate = function(c)
			c.discovery.probability = 1
		end,
	},
	{
		message = "discovery.guaranteeUnits",
		mutate = function(c)
			c.discovery.guaranteeUnits = 199999.5
		end,
	},
	{
		message = "exceed throughput",
		mutate = function(c)
			c.throughput.maxMaximumLines = 3
		end,
	},
	{
		message = "exceed throughput",
		mutate = function(c)
			c.machines[1].tiers[3].rate = 31
		end,
	},
	{
		message = "maxEligiblePerSecond",
		mutate = function(c)
			c.throughput.maxEligiblePerSecond = math.huge
		end,
	},
	{
		message = "starterLane.clearRate",
		mutate = function(c)
			c.starterLane.clearRate = 0
		end,
	},
	{
		message = "start at minArchives 0",
		mutate = function(c)
			c.ranks[1].minArchives = 1
		end,
	},
	{
		message = "strictly ascending",
		mutate = function(c)
			c.ranks[3].minArchives = 1
		end,
	},
	{
		message = "title must be",
		mutate = function(c)
			c.ranks[2].title = ""
		end,
	},
	{
		message = "clearanceLevel must be 1",
		mutate = function(c)
			c.promotions[1].clearanceLevel = 2
		end,
	},
	{
		message = "intelMultiplier",
		mutate = function(c)
			c.promotions[1].intelMultiplier = 0.9
		end,
	},
	{
		message = "intelFee",
		mutate = function(c)
			c.promotions[1].intelFee = -1
		end,
	},
	{
		message = "schemaVersion",
		mutate = function(c)
			c.schemaVersion = 0
		end,
	},
}
for _, case in cases do
	local broken = copy(defs)
	case.mutate(broken)
	local errors = Catalog.validate(broken)
	local matched = false
	for _, message in errors do
		if string.find(message, case.message, 1, true) then
			matched = true
		end
	end
	assert(matched, "expected '" .. case.message .. "', got: " .. table.concat(errors, "; "))
end
-- Several problems are reported together rather than stopping at the first.
local broken = copy(defs)
broken.discovery.probability = 2
broken.ranks[1].minArchives = 3
assert(#Catalog.validate(broken) >= 2)

print("Catalog: approved values, immutability, rank boundaries and invalid definitions passed")
