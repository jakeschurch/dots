for _, name in ipairs({
  "buffers",
  "git",
  "highlight",
  "templates",
  "trim",
}) do
  require("core.autocmd." .. name)
end
