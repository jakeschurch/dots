for _, filepath in
  ipairs(vim.fn.globpath(
    vim.fn.stdpath("config") .. "/lua/plugin",
    "**/*.lua", -- Ensure it searches all subdirectories
    true, -- Scan recursively
    true -- Return as a list
  ))
do
  local module_path = filepath:match("lua/(.*)%.lua$"):gsub("/", ".") -- Convert path to module format
  require(module_path)
end
