for _, file in
  ipairs(
    vim.fn.readdir(
      vim.fn.stdpath("config") .. "/lua/plugin",
      [[v:val =~ '\.lua$']]
    )
  )
do
  require("plugin." .. file:gsub("%.lua$", ""))
end
