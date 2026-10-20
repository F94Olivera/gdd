--!strict
-- Structural smoke test only. Add behavioral tests alongside actual game rules.
local fs = require("@lune/fs")
local roblox = require("@lune/roblox")
local serde = require("@lune/serde")
local project = serde.decode("json", fs.readFile("default.project.json"))
assert(project.tree["$className"] == "DataModel", "Expected a DataModel root")
for _, path in
	{
		"src/server/Bootstrap.server.luau",
		"src/client/Bootstrap.client.luau",
		"src/shared/Catalog.luau",
		"src/server/ProductionLedger.luau",
		"src/server/PlotGraph.luau",
	}
do
	assert(fs.readFile(path):match("^%-%-!strict"), path .. " must enable strict mode")
end
-- The engine runtime is validated separately in Studio.
local place = roblox.deserializePlace(fs.readFile("build/game.rbxlx"))
assert(place.ServerScriptService.Server.Bootstrap.ClassName == "Script")
assert(place.StarterPlayer.StarterPlayerScripts.Client.Bootstrap.ClassName == "LocalScript")
assert(place.ReplicatedStorage.Shared.ClassName == "Folder")
assert(place.ReplicatedStorage.Shared.Catalog.ClassName == "ModuleScript")
assert(place.ServerScriptService.Server.ProductionLedger.ClassName == "ModuleScript")
assert(place.ServerScriptService.Server.PlotGraph.ClassName == "ModuleScript")
print("Repository smoke checks passed")
