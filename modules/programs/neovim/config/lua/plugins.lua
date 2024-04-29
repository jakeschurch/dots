local scan = require("plenary.scandir")
local utils = require("utils")

local function getFiles(path)
	local files = scan.scan_dir(path, { hidden = false, depth = 1 })
	local res = {}
	for _, file in ipairs(files) do
		if file:match("%.lua$") then
			res[#res + 1] = file
		end
	end
	return res
end

local function getPluginBasename(path)
	return "plug." .. string.match(path, "^.+/(.+).lua$")
end

local function requireFile(file)
	local status_ok, _ = pcall(require, file)
	if not status_ok then
		vim.notify("Error loading plugin: " .. file, vim.log.levels.ERROR)
	end
end

local pluginPath = os.getenv("XDG_CONFIG_HOME") .. "/nvim/lua/plug"
local pluginFiles = utils.filter(function(file)
	return not file:match(".*init.lua$")
end, getFiles(pluginPath))

local loadPlugin = utils.pipe(getPluginBasename, requireFile)

utils.map(loadPlugin, pluginFiles)
