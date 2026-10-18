--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")

local function run(command: string, args: { string })
	local result = process.exec(command, args)
	if result.stdout ~= "" then
		print(result.stdout)
	end
	if result.stderr ~= "" then
		warn(result.stderr)
	end
	assert(result.ok, command .. " failed (exit " .. tostring(result.code) .. ")")
end

run("stylua", { "--check", "src", "scripts", "tests" })
run("selene", { "src" })
if not fs.isDir("build") then
	fs.writeDir("build")
end
run("rojo", { "build", "default.project.json", "--output", "build/game.rbxlx" })
run("lune", { "run", "tests/smoke.luau" })
run("lune", { "run", "tests/production.luau" })
print("All checks passed")
