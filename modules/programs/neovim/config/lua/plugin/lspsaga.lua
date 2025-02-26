local quit_keys = { "<ESC>", "q" }
local open_keys = { "<CR>", "o", "e" }

vim.wo.signcolumn = "yes"

require("lspsaga").setup({
  ui = {
    debounce = 250,
    code_action = "☝️",
    colors = {
      -- float window normal background color
      normal_bg = "#3c3836", -- Gruvbox Dark Soft background
      -- title background color
      title_bg = "#fabd2f",  -- Gruvbox Soft Yellow
      red = "#fb4934",       -- Gruvbox red
      magenta = "#d3869b",   -- Gruvbox purple (soft)
      orange = "#fe8019",    -- Gruvbox orange
      yellow = "#d79921",    -- Gruvbox yellow
      green = "#b8bb26",     -- Gruvbox green
      cyan = "#8ec07c",      -- Gruvbox cyan
      blue = "#83a598",      -- Gruvbox blue
      purple = "#d3869b",    -- Gruvbox purple (soft)
      white = "#ebdbb2",     -- Gruvbox light grey
      black = "#1d2021",     -- Gruvbox black
    },
  },
  symbol_in_winbar = {
    enable = true,
    show_file = true,
    folder_level = 1,
    hide_keyword = true,
    separator = " > ",
  },
  finder = {
    open = open_keys,
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = quit_keys,
  },
  definition = {
    edit = "e",
    vsplit = "v",
    split = "s",
    tabe = "t",
    quit = "<esc>",
  },
  code_action = {
    num_shortcut = true,
    extend_gitsigns = true,
    keys = {
      quit = quit_keys,
      exec = open_keys,
    },
  },
  lightbulb = {
    enable = true,
    enable_in_insert = false,
    sign = true,
    sign_priority = 40,
    virtual_text = false,
    debounce = 1000,
  },
  diagnostic = {
    show_code_action = true,
    show_source = true,
    jump_num_shortcut = true,
    keys = {
      exec_action = "<CR>",
      quit = "q",
      go_action = "g",
    },
  },
  rename = {
    exec = "<CR>",
    mark = "x",
    in_select = true,
    whole_project = true,
    quit = "<ESC>",
  },
  callhierarchy = {
    show_detail = false,
    keys = {
      edit = "e",
      vsplit = "s",
      split = "i",
      tabe = "t",
      jump = "o",
      quit = "q",
      expand_collapse = "u",
    },
  },
})

local keymap = vim.keymap.set

keymap("n", "[d", function()
  require("lspsaga.diagnostic"):goto_prev({
    severity = vim.diagnostic.severity.ERROR,
  })
end)

keymap("n", "]d", function()
  require("lspsaga.diagnostic"):goto_next({
    severity = vim.diagnostic.severity.ERROR,
  })
end)

keymap("n", "[g", "<cmd>Lspsaga diagnostic_jump_prev<CR>", {})
keymap("n", "]g", "<cmd>Lspsaga diagnostic_jump_next<CR>")
--
-- Call hierarchy
keymap("n", "<Leader>hc", "<cmd>Lspsaga incoming_calls<CR>")
keymap("n", "<Leader>ho", "<cmd>Lspsaga outgoing_calls<CR>")

vim.keymap.set(
  "n",
  "<leader>qf",
  "<cmd>Lspsaga code_action<cr>",
  { noremap = true, silent = true }
)

vim.keymap.set(
  "v",
  "<leader>qf",
  "<cmd>Lspsaga code_action<cr>",
  { noremap = true, silent = true }
)
