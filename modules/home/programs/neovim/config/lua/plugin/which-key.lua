local which_key = require("which-key")
local ignored_filetypes = require("utils").ignored_filetypes

local setup = {
  preset = "helix",
  plugins = {
    marks = false,
    registers = false,
    spelling = {
      enabled = true,
      suggestions = 10,
    },
    presets = {
      operators = true,
      motions = true,
      text_objects = true,
      windows = true,
      nav = true,
      z = true,
      g = true,
    },
  },
  replace = {
    ["<space>"] = "SPC",
    ["<CR>"] = "RET",
    ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = "»",
    separator = "➜",
    group = "+",
  },
  keys = {
    scroll_down = "<c-j>",
    scroll_up = "<c-k>",
  },
  win = {
    no_overlap = true,
    border = "single",
    padding = { 2, 2, 2, 2 },
    height = { min = 4, max = 25 },
  },
  layout = {
    width = { min = 20, max = 50 },
    spacing = 3,
  },
  show_help = false,
  debug = false,
  triggers = { "<leader>" },
  disable = {
    ft = ignored_filetypes,
  },
}

-- Utils plugin mappings
local utils_mappings = {
  {
    "<leader>?",
    function()
      require("which-key").show({ global = false })
    end,
    desc = "Buffer Local Keymaps (which-key)",
  },
  { "<leader>df", "<cmd>lua require('utils.diff')()<CR>", desc = "Diff With" },
}

-- Git plugin mappings
local git_mappings = {
  { "<leader>gf", "<cmd>0Gclog<CR>", desc = "File history" },
  { "<leader>gl", "<cmd>Gclog<CR>", desc = "Git Log Information" },
}

which_key.setup(setup)
which_key.add(utils_mappings)
which_key.add(git_mappings)
