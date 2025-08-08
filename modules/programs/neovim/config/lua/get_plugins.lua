_G.loaded_plugins = _G.loaded_plugins or {}

for _, filepath in
	ipairs(vim.fn.globpath(
		vim.fn.stdpath("config") .. "/lua/plugin",
		"**/*.lua", -- Ensure it searches all subdirectories
		true, -- Scan recursively
		true -- Return as a list
	))
do
	local module_path = filepath:match("lua/(.*)%.lua$"):gsub("/", ".") -- Convert path to module format
	if not _G.loaded_plugins[module_path] then
		local ok, err = pcall(require, module_path)
		if ok then
			_G.loaded_plugins[module_path] = true
		else
			vim.notify("Failed to load " .. module_path .. ": " .. err, vim.log.levels.ERROR)
		end
	end
end
