local diffview = require("diffview")
local actions = require("diffview.actions")

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
    DiffviewOpen = { "--untracked-files=no", "--imply-local" },
    DiffviewFileHistory = { "--base=LOCAL" },
  },
  hooks = {
    view_opened = actions.toggle_files,
  },
  view = {
    merge_tool = {
      layout = "diff4_mixed",
      disable_diagnostics = true,
      winbar_info = true,
    },
  },
  keymaps = {
    disable_defaults = true,
    view = {
      { "n", "[h",         actions.select_next_entry,         { desc = "Next entry" } },
      { "n", "]h",         actions.select_prev_entry,         { desc = "Previous entry" } },
      { "n", "q",          actions.close,                     { desc = "Close" } },
      { "n", "<leader>b",  actions.toggle_files,              { desc = "Toggle file panel" } },
      { "n", "[x",         actions.prev_conflict,             { desc = "Previous conflict" } },
      { "n", "]x",         actions.next_conflict,             { desc = "Next conflict" } },
      { "n", "<leader>ho", actions.conflict_choose("ours"),   { desc = "Choose OURS" } },
      { "n", "<leader>ht", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
      { "n", "<leader>hr", actions.conflict_choose("none"),   { desc = "Delete conflict" } },
    },
    file_panel = {
      {
        "n", "cc",
        "<Cmd>Git commit <bar> wincmd J<CR>",
        { desc = "Commit staged changes" },
      },
      {
        "n", "ca",
        "<Cmd>Git commit --amend <bar> wincmd J<CR>",
        { desc = "Amend the last commit" },
      },
      {
        "n", "c<space>",
        ":Git commit ",
        { desc = "Populate command line with \":Git commit \"" },
      },
    },
  },
})

vim.keymap.set("n", "<leader>dv", function()
  -- Simply use DiffviewOpen command - it auto-detects merge state
  vim.cmd("DiffviewOpen")
end, { desc = "Smart Git Diff (Diffview or merge tool)" })
