local palette = require("lib.palette")

local quit_keys = { "<ESC>", "q" }
local open_keys = { "<CR>", "o", "e" }
local edit_keys = { "a", "i" }

vim.wo.signcolumn = "yes"

require("lspsaga").setup({
  ui = {
    enable = true,
    debounce = 250,
    -- Nerd Font lightbulb (md-lightbulb), not the ☝️ emoji: that codepoint is
    -- absent from JetBrainsMono Nerd Font, so it fell back to the emoji font
    -- and rendered as a colour glyph in an otherwise monochrome gutter.
    code_action = "󰌵",
    colors = {
      normal_bg = palette.bg1,
      title_bg = palette.yellow,
      red = palette.red,
      magenta = palette.purple,
      orange = palette.orange,
      yellow = palette.yellow,
      green = palette.green,
      cyan = palette.aqua,
      blue = palette.blue,
      purple = palette.purple,
      white = palette.fg1,
      black = palette.bg0,
    },
  },
  -- The winbar is owned by plugin/winbar.lua (filename + directory pills).
  symbol_in_winbar = {
    enable = false,
  },
  finder = {
    open = open_keys,
    edit = edit_keys,
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = quit_keys,
  },
  definition = {
    open = open_keys,
    edit = edit_keys,
    vsplit = "v",
    split = "s",
    tabe = "t",
    quit = quit_keys,
  },
  code_action = {
    show_code_action = true,
    num_shortcut = true,
    extend_gitsigns = true,
    show_server_name = true,
    extend_relatedInformation = true,
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
