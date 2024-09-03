local g = vim.g

--disable_distribution_plugins
g.loaded_gzip = 1
g.loaded_tar = 1
g.loaded_tarPlugin = 1
g.loaded_zip = 1
g.loaded_zipPlugin = 1
g.loaded_getscript = 1
g.loaded_getscriptPlugin = 1
g.loaded_vimball = 1
g.loaded_vimballPlugin = 1
g.loaded_matchit = 1
g.loaded_matchparen = 1
g.loaded_2html_plugin = 1
g.loaded_logiPat = 1
g.loaded_rrhelper = 1

local options = {
  autoindent = true,
  autoread = true,
  backup = false,
  breakindent = true,
  breakindentopt = "min:4,shift:4",
  clipboard = "unnamedplus",
  cmdheight = 0,
  cursorline = true,
  expandtab = true,
  hidden = true,
  history = 2000,
  hlsearch = false,
  ignorecase = true,
  inccommand = "nosplit", -- real-time [:s]ubstitute
  infercase = true,
  list = true,
  listchars = "tab:  ,lead:⋅,trail:⋅,",
  number = true,
  numberwidth = 4,
  pumheight = 5,
  relativenumber = true,
  shiftround = true,
  shiftwidth = 2,
  showbreak = "↳",
  showmatch = true,
  showcmd = false,
  foldenable = false,

  timeout = true,
  timeoutlen = 500,
  ttimeoutlen = 500,
  updatetime = 2000,
  redrawtime = 2000,

  scrolloff = 999,
  sidescroll = 5,

  smartcase = true,
  smartindent = true,
  softtabstop = 2,
  splitright = false,
  swapfile = false,
  synmaxcol = 500,
  tabstop = 2, -- default shifts / tabs,
  termguicolors = true,
  undodir = os.getenv("HOME") .. "/.config/nvim/.undo",
  undofile = true,
  whichwrap = "b,s",
  wildmode = "full",
  wrap = true,
  writebackup = false,
  fillchars = {
    diff = "╱",
    fold = " ",
    eob = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "",
  },
}

vim.cmd([[ set nolist ]])

vim.opt.mouse:append("a")
vim.opt.shortmess:append("c")
-- shortmess = "filnxtToOFIc",

vim.opt.foldenable = false

if vim.fn.executable("rg") == 1 then
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.grepprg = "rg --vimgrep --no-heading --smart-case"
end

for k, v in pairs(options) do
  vim.opt[k] = v
end
