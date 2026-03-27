local _rainbow_delims = require("rainbow-delimiters")

vim.g.rainbow_delimiters = {
  condition = function()
    return vim.treesitter.highlighter.active[vim.api.nvim_get_current_buf()]
  end,
  strategy = {
    [""] = "rainbow-delimiters.strategy.global",
    vim = "rainbow-delimiters.strategy.local",
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
  },
  priority = {
    [""] = 110,
    lua = 210,
  },
  highlight = {
    "RainbowDelimiterRed",
    "RainbowDelimiterBlue",
    "RainbowDelimiterOrange",
    "RainbowDelimiterCyan",
    "RainbowDelimiterViolet",
    "RainbowDelimiterGreen",
    "RainbowDelimiterYellow",
  },
}
