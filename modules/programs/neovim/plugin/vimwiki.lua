vim.treesitter.language.register("markdown", "vimwiki")

vim.cmd([[
let g:vimwiki_tag_format = {'pre': '\(^[ -]*tags\s*: .*\)\@<=',
\ 'pre_mark': '@', 'post_mark': '', 'sep': '>><<'}
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
  {
    path = "~/Documents/wiki/work/fieldguide",
    syntax = syntax,
    ext = syntax_ext,
  },
  { path = "~/Documents/wiki/personal", syntax = syntax, ext = syntax_ext },
}

-- Remap '-' to <CMD>Oil<CR> in Vimwiki and Markdown filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vimwiki", "markdown" },
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "-",
      "<CMD>Oil<CR>",
      { noremap = true, silent = true }
    )
  end,
})
