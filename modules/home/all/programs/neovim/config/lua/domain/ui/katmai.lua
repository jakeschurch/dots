require("parks").setup({
  variant = "dark",
  transparent = false,
  dim_inactive = false,
  styles = {
    comments = { italic = true },
    keywords = {},
    functions = {},
    types = {},
    strings = {},
    variables = {},
    booleans = { bold = true },
  },
})

vim.cmd([[
colorscheme parks-katmai

highlight clear SignColumn
]])

vim.api.nvim_set_hl(0, "SpellBad", {
  undercurl = true,
  sp = require("lib.palette").red,
})
