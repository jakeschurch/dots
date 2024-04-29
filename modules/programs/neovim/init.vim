lua <<EOF

vim.g.mapleader = " "

require("impatient")
require("maps")
require("options")
require("autocommands")
require("plugins")


vim.cmd [[
  iabbrev fp functional programming

  let winfixbuf = "off" 

  nmap <leader>gh :diffget //2<CR>
  nmap <leader>gp :diffget //3<CR>

  set rtp+=~/.local/share/nvim/site/pack/packer/start/himalaya/vim

  iab <expr> TODAY strftime("%Y-%m-%d")
  iab <expr> TIME strftime("%H:%M")
]]
EOF

set updatetime=200
set guicursor=a:blinkon20

set signcolumn=yes:1

function! Notes()
  execute ":VimwikiMakeDiaryNote"
  execute ":split"
  execute ":VimwikiIndex"
  execute ":e ~/Documents/wiki/TODO.md"
  exe "normal \<c-w>v\<c-w>L"
endfunction

nnoremap ]n :call Notes()<cr>

function! GitStatus()
  let [a,m,r] = GitGutterGetHunkSummary()
  return printf('+%d ~%d -%d', a, m, r)
endfunction
