local highlight = {
  "Whitespace",
  "NonText",
}

require("ibl").setup({
  scope = { enabled = false },
  indent = { highlight = highlight, tab_char = { "⋅" }, char = "|" },
  whitespace = {
    highlight = highlight,
    remove_blankline_trail = false,
  },
  exclude = {
    filetypes = {
      "TelescopePrompt",
      "dashboard",
      "fugitive",
      "git",
      "gitcommit",
      "help",
      "json",
      "log",
      "markdown",
      "startify",
      "txt",
      "undotree",
    },
    buftypes = { "terminal", "nofile", "prompt", "virtual_text" },
  },
})
