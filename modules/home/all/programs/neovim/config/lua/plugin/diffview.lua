local diffview = require("diffview")

diffview.setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  use_icons = true,
  icons = {
    folder_closed = "",
    folder_open = "",
    folder_empty = "ﰊ",
  },
  default_args = {
    DiffviewOpen = { "HEAD" },
    DiffviewFileHistory = {},
  },
  view = {
    default = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
      winbar_info = false,
    },
  },
  keymaps = {
    view = {
      ["[h"] = diffview.config.actions.select_next_entry,
      ["]h"] = diffview.config.actions.select_prev_entry,
      ["q"] = diffview.config.actions.close,
    }
  }
})

local maps = {
  { "<leader>ho", function() require("diffview.config").actions.conflict_choose("ours") end,   desc = "Choose Ours" },
  { "<leader>ht", function() require("diffview.config").actions.conflict_choose("theirs") end, desc = "Choose Theirs" },
  { "<leader>hr", function() require("diffview.config").actions.conflict_choose("none") end,   desc = "Choose Base" },
}

require("which-key").add(maps, { mode = "n" })

vim.keymap.set(
  "n",
  "<leader>dv",
  function() diffview.open() end,
  { desc = "Smart Git Diff (Diffview or file)" }
)
