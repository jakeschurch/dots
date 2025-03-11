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
    -- winblend = 0,
    -- highlights = {
    --   border = "Normal",
    --   background = "Normal",
    -- },
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
  "*.ts",
  "*.graphql",
  "*.tsx",
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPre" }, {
  pattern = toggleterm_pattern,
  group = "disable_folding_toggleterm",
  callback = function(ev)
    local bufnr = ev.buf
    vim.api.nvim_buf_set_option(bufnr, "foldmethod", "manual")
    vim.api.nvim_buf_set_option(bufnr, "foldexpr", "0")
    vim.api.nvim_buf_set_option(bufnr, "foldtext", "foldtext()")
  end,
})

vim.api.nvim_create_user_command("ToggleTermClear", function()
  local buffers = vim.api.nvim_list_bufs()

  for _, buf in ipairs(buffers) do
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local buf_num = vim.api.nvim_buf_get_number(buf)

    if buf_name:find("toggleterm#") then
      local term_id = buf_num
      vim.cmd(string.format("bdelete! %d", term_id))
      require("toggleterm.terminal").Terminal
        :new({ direction = "vertical" })
        :toggle()
    end
  end
end, {})

---@diagnostic disable-next-line: unused-function
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set(
    "t",
    "<C-x>",
    "<cmd>ToggleTermClear<CR>",
    { noremap = true, silent = true }
  )
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

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

-- Create a hidden terminal instance
local Terminal = require("toggleterm.terminal").Terminal
local hidden_term = Terminal:new({
  direction = "float", -- Match the direction in the setup
  hidden = true, -- Keep the terminal hidden initially
  on_open = function(term)
    vim.cmd("startinsert!") -- Start in insert mode when opened
  end,
})

-- Override the default toggleterm mapping to toggle the hidden terminal
vim.keymap.set({ "n", "t" }, [[<c-\>]], function()
  hidden_term:toggle()
end, { noremap = true, silent = true })

local hidden_term_group =
  vim.api.nvim_create_augroup("HiddenTermGroup", { clear = true })

vim.api.nvim_create_autocmd("VimEnter", {
  group = hidden_term_group,
  pattern = "*",
  callback = function()
    hidden_term:spawn()
  end,
})
