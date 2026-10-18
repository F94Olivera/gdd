--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local Runner = require("./models/BalanceRunner")
local Scenarios = require("./balanceScenarios")

-- Sorted object keys make exports byte-reproducible, independent of table hashing.
local function canonical(value: any): string
	if type(value) ~= "table" then
		return serde.encode("json", value)
	end
	if #value > 0 then
		local parts = {}
		for _, v in value do
			table.insert(parts, canonical(v))
		end
		return "[" .. table.concat(parts, ",") .. "]"
	end
	local keys = {}
	for k in value do
		table.insert(keys, k)
	end
	table.sort(keys)
	local parts = {}
	for _, k in keys do
		table.insert(parts, serde.encode("json", k) .. ":" .. canonical(value[k]))
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

local scenarios = Scenarios.all()
local results = {}
for _, s in scenarios do
	local r = Runner.run(s)
	table.insert(results, r)
	print(s.id, "A", r.totals.accepted, "P", r.totals.processed, "online", r.totals.online)
end
local revision = process.exec("git", { "rev-parse", "HEAD" })
local status = process.exec("git", { "status", "--porcelain" })
local version = process.exec("lune", { "--version" })
assert(revision.ok and status.ok and version.ok, "provenance unavailable")
local artifact = {
	schemaVersion = 1,
	modelVersion = "deterministic-runner-v1",
	balanceVersion = "D011-D012-experimental-v1",
	revision = revision.stdout:gsub("%s+$", ""),
	dirty = status.stdout ~= "",
	lune = version.stdout:gsub("%s+$", ""),
	seed = "not applicable",
	command = "lune run scripts/balance.luau",
	units = "seconds, documents, Intel",
	scenarios = scenarios,
	results = results,
}
fs.writeDir("build/balance")
fs.writeFile("build/balance/deterministic.json", canonical(artifact) .. "\n")
print("Wrote build/balance/deterministic.json")
