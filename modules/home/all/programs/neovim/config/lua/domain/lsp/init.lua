return {
  -- servers is a data table; lsp.lua requires it directly.
  first = { "servers", "lsp" },
  lazy = {
    lspsaga = "LspAttach",
    otter = true,
    trouble = true,
    ["yaml-schemas"] = true,
  },
}
