local toggleterm = require("toggleterm")
local keymap = require("utils").keymap

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
  direction = "vertical",
  open_mapping = [[<c-\>]],
  persist_size = true,
  shade_filetypes = {},
  shade_terminals = true,
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

---@diagnostic disable-next-line: unused-function
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
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

vim.cmd(
  'autocmd TermEnter term://*toggleterm#* tnoremap <silent><c-t> <Cmd>exe v:count1 . "ToggleTerm"<CR>'
)
