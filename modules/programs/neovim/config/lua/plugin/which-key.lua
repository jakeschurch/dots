local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

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
    border = "single",
    position = "bottom",
    margin = { 1, 0, 1, 0 },
    padding = { 2, 2, 2, 2 },
    winblend = 0,
  },
  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 3,
    align = "left",
  },
  show_help = false,
  triggers = { "<leader>" },
}

local leader_opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
}


-- Utils plugin mappings
local utils_mappings = {
  d = {
    f = { "<cmd>lua require('utils.diff')()<CR>", "Diff With" },
  },
}

-- Git plugin mappings
local git_mappings = {
  g = {
    L = { "", "Git Blame Information" },
    f = { "<cmd>0Gclog<CR>", "File history" },
    l = { "<cmd>Gclog<CR>", "Git Log Information" },
    name = "Git",
  },
}

which_key.setup(setup)
which_key.add(utils_mappings, leader_opts)
which_key.add(git_mappings, leader_opts)
