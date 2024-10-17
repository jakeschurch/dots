vim.treesitter.language.register("markdown", "vimwiki")

vim.cmd([[
let g:vimwiki_tag_format = {'pre': '\(^[ -]*tags\s*: .*\)\@<=',
\ 'pre_mark': '@', 'post_mark': '', 'sep': '>><<'}

" Unmap the '-' keybinding in normal mode for Vimwiki
autocmd FileType vimwiki silent! nunmap <buffer> -
]])

local g = vim.g

g.automatic_nested_syntaxes = 1
g.vimwiki_autowriteall = 1
g.vimwiki_auto_chdir = 1
g.vimwiki_commentstring = "# %s"

g.vimwiki_filetypes = { "markdown" }
-- g.vimwiki_sync_branch = "main"
g.vimwiki_ext = "markdown"

local syntax = "markdown"
local syntax_ext = ".md"

g.vimwiki_list = {
  { path = "~/Documents/wiki/personal", syntax = syntax, ext = syntax_ext },
  { path = "~/Documents/wiki/engineering", syntax = syntax, ext = syntax_ext },
  { path = "~/Documents/wiki/ventures", syntax = syntax, ext = syntax_ext },
  { path = "~/Documents/wiki/work", syntax = syntax, ext = syntax_ext },
  {
    path = "~/Documents/wiki/work/fieldguide",
    syntax = syntax,
    ext = syntax_ext,
  },
  { path = "~/Documents/wiki/books", syntax = syntax, ext = syntax_ext },
}
