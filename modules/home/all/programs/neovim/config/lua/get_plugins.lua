for _, filepath in
  ipairs(vim.fn.globpath(
    vim.fn.stdpath("config") .. "/lua/plugin",
    "**/*.lua",
    true,
    true
  ))
do
  local module_path = filepath:match("lua/(.*)%.lua$"):gsub("/", ".")
  local ok, err = pcall(require, module_path)
  if not ok then
    vim.notify(
      "Failed to load " .. module_path .. ": " .. err,
      vim.log.levels.ERROR
    )
  end
end
