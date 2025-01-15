local quit_keys = { "<ESC>", "q" }
local open_keys = { "<CR>", "o", "e" }

vim.wo.signcolumn = "yes"

require("lspsaga").setup({
  ui = {
    debounce = 250,
    code_action = "☝️",
    -- TODO: make colors gruvbox
    colors = {
      --float window normal background color
      normal_bg = "#1d1536",
      --title background color
      title_bg = "#afd700",
      red = "#e95678",
      magenta = "#b33076",
      orange = "#FF8700",
      yellow = "#f7bb3b",
      green = "#afd700",
      cyan = "#36d0e0",
      blue = "#61afef",
      purple = "#CBA6F7",
      white = "#d1d4cf",
      black = "#1c1c19",
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
    debounce = 100,
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
