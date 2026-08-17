-- Inline diagnostics rendered as rounded pills at the end of the cursor line,
-- instead of native virtual text smeared across every line.
--
-- Native `virtual_text` is already disabled in plugin/lsp.lua; this file loads
-- after it alphabetically, so the setting below is belt-and-braces for the case
-- where something re-enables it.
require("tiny-inline-diagnostic").setup({
  preset = "modern",

  signs = {
    left = "",
    right = "",
    diag = "●",
    arrow = "    ",
    up_arrow = "    ",
    vertical = " │",
    vertical_end = " └",
  },

  options = {
    -- Show the source only when more than one LSP is reporting, otherwise it
    -- is just noise on every message.
    show_source = { enabled = false, if_many = true },
    use_icons_from_diagnostic = true,
    set_arrow_to_diag_color = true,

    -- Wrap long messages rather than letting them run off-screen.
    softwrap = 30,
    break_line = { enabled = false, after = 30 },

    -- Stack multiple diagnostics on the same line instead of hiding all but one.
    multilines = { enabled = true, always_show = false },

    -- Keep the pill visible while the cursor sits on the line.
    show_all_diags_on_cursorline = false,
    enable_on_insert = false,
    enable_on_select = false,

    overflow = { mode = "wrap" },
    virt_texts = { priority = 2048 },

    severity = {
      vim.diagnostic.severity.ERROR,
      vim.diagnostic.severity.WARN,
      vim.diagnostic.severity.INFO,
      vim.diagnostic.severity.HINT,
    },
  },
})

vim.diagnostic.config({ virtual_text = false })
