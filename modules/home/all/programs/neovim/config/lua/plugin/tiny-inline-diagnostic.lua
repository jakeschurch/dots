-- Inline diagnostics as rounded pills at end of line: a bare count on every
-- line that has them, expanding to the full messages on the line the cursor is
-- on.
--
-- Native `virtual_text` is already disabled in plugin/lsp.lua; this file loads
-- after it alphabetically, so the setting below is belt-and-braces for the case
-- where something re-enables it.
require("tiny-inline-diagnostic").setup({
  preset = "modern",

  options = {
    -- Counts off the cursor line, messages on it. `display_count` requires
    -- `multilines.enabled`, and `always_show` is what puts the counts on every
    -- line rather than only on multiline diagnostics.
    add_messages = {
      messages = true,
      display_count = true,
      use_max_severity = true,
    },
    multilines = {
      enabled = true,
      always_show = true,
    },

    -- Expanding should show every diagnostic on the line, not just the one
    -- directly under the cursor.
    show_all_diags_on_cursorline = true,
    show_diags_only_under_cursor = false,

    use_icons_from_diagnostic = true,
    set_arrow_to_diag_color = true,

    -- Show the source only when more than one is reporting, otherwise it is
    -- just noise on every message.
    show_source = { enabled = false, if_many = true },

    softwrap = 30,
    overflow = { mode = "wrap" },
    break_line = { enabled = false, after = 30 },

    enable_on_insert = false,
    enable_on_select = false,

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
