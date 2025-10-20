local toggleterm = require("toggleterm")

function table.contains(table, element)
  for _, value in pairs(table) do
    if value == element then
      return true
    end
  end
  return false
end

local shell = nil
local ft_shell_map = {
  python = "python3",
  toggleterm = shell,
}

toggleterm.setup({
  close_on_exit = false,
  direction = "float",
  open_mapping = nil,
  persist_size = true,
  shade_filetypes = {},
  shade_terminals = false,
  shading_factor = "3",
  start_in_insert = true,
  insert_mappings = true,
  hide_numbers = true,
  size = 80,
  scrollback = 1000,
  auto_scroll = false,
  autochdir = true,
  float_opts = {
    border = "curved",
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
  -- for filetype repl mapping based on current filetype
  shell = function()
    local ft = vim.bo.filetype
    -- check if ft exists in ft_shell_map
    if table.contains(ft_shell_map, ft) then
      shell = ft_shell_map[ft]
    else
      shell = vim.o.shell
    end
    return shell
  end,
})

vim.api.nvim_create_augroup("disable_folding_toggleterm", { clear = true })
local toggleterm_pattern = {
  "term://*#toggleterm#*",
  "term://*::toggleterm::*",
}

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = toggleterm_pattern,
  group = "disable_folding_toggleterm",
  callback = function(ev)
    local bufnr = ev.buf
    local winid = vim.fn.bufwinid(bufnr)
    if winid ~= -1 then
      vim.api.nvim_set_option_value("foldmethod", "manual", { win = winid })
      vim.api.nvim_set_option_value("foldexpr", "0", { win = winid })
      vim.api.nvim_set_option_value("foldtext", "foldtext()", { win = winid })
    end
  end,
})

local trim_spaces = true
vim.keymap.set({ "n", "v" }, "<space>h", function()
  toggleterm.send_lines_to_terminal(
    "single_line",
    trim_spaces,
    { args = vim.v.count }
  )
end)

-- Save the original value of ttimeoutlen
local original_ttimeoutlen = vim.o.ttimeoutlen

-- Set ttimeoutlen to 500 when entering a terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.o.ttimeoutlen = 500
  end,
})

-- Reset ttimeoutlen to its original value when leaving a terminal buffer
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*",
  callback = function()
    vim.o.ttimeoutlen = original_ttimeoutlen
  end,
})

-- Optional: Handle toggleterm.nvim
vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "*",
  callback = function()
    vim.o.ttimeoutlen = 500
  end,
})

vim.api.nvim_create_autocmd("TermLeave", {
  pattern = "*",
  callback = function()
    vim.o.ttimeoutlen = original_ttimeoutlen
  end,
})

-- Create a pre-spawned terminal that's ready to go
local Terminal = require("toggleterm.terminal").Terminal

-- This will be the terminal that responds to <c-\>
local main_term = Terminal:new({
  direction = "float",
  hidden = true,
  on_open = function(_)
    vim.cmd("startinsert!")
    -- Ensure we're in insert mode
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Esc>i", true, false, true),
      "n",
      false
    )
  end,
})

-- Override the default toggle to use our pre-spawned terminal
vim.keymap.set({ "n", "t", "i" }, "<c-\\>", function()
  main_term:toggle()
end, { noremap = true, silent = true })

function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-x>", [[<C-\><C-n><C-w>]], opts)
end

vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

-- Pre-spawn the terminal on startup
local preload_group =
  vim.api.nvim_create_augroup("PreloadTermGroup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = preload_group,
  pattern = "*",
  callback = function()
    -- Defer to ensure everything is loaded
    vim.defer_fn(function()
      -- Spawn the terminal in the background
      main_term:spawn()
      -- Immediately hide it so it's ready but not visible
      if main_term:is_open() then
        main_term:close()
      end
    end, 100) -- 100ms delay to ensure Neovim is fully initialized
  end,
})
