vim.loader.enable()

local g = vim.g

g.codeium_enabled = false

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
  jumpoptions = "stack",
  autoindent = false,
  copyindent = true,
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
  incsearch = true,
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

  redrawtime = 1000,

  -- scrolloff = 999,
  -- sidescroll = 5,

  smartcase = true,
  smartindent = true,
  softtabstop = 2,
  splitright = false,
  swapfile = false,
  synmaxcol = 500,
  tabstop = 2, -- default shifts / tabs,
  background = "dark",
  termguicolors = true,
  undodir = os.getenv("HOME") .. "/.config/nvim/.undo",
  undofile = true,
  whichwrap = "b,s",
  wildmode = "full",
  wrap = true,
  smoothscroll = true,
  writebackup = false,
  fillchars = {
    diff = "╱",
    fold = " ",
    eob = " ",
    foldopen = "",
    foldsep = " ",
    foldclose = "",
  },
  laststatus = 3,
  statuscolumn = [[%!v:lua.require'plugin.signcol'.column()]],
}

vim.opt.mouse:append("a")

if vim.fn.has("mac") == 0 then
  if os.getenv("WAYLAND_DISPLAY") then
    vim.g.clipboard = {
      name = "wl-clipboard",
      copy = {
        ["+"] = "wl-copy",
        ["*"] = "wl-copy --primary",
      },
      paste = {
        ["+"] = "wl-paste --no-newline",
        ["*"] = "wl-paste --no-newline --primary",
      },
      cache_enabled = 0,
    }
  else
    -- OSC 52: works through SSH, tmux, any depth
    local osc52 = require("vim.ui.clipboard.osc52")
    vim.g.clipboard = {
      name = "OSC 52",
      copy = {
        ["+"] = osc52.copy("+"),
        ["*"] = osc52.copy("*"),
      },
      paste = {
        ["+"] = osc52.paste("+"),
        ["*"] = osc52.paste("*"),
      },
    }
  end
end

if vim.fn.executable("rg") == 1 then
  vim.opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  vim.opt.grepprg = "rg --vimgrep --hidden --pcre2 --no-heading --smart-case"
end

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.opt.shortmess:append("c")
