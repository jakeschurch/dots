vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "")
  .. "|setlocal wrap< linebreak< list< tw< wrapmargin< colorcolumn< comments< "
  .. "formatoptions< formatlistpat< formatexpr<|silent! nunmap <buffer> gw"

vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.list = false
vim.opt_local.wrapmargin = 0
vim.opt_local.colorcolumn = "0"
vim.opt_local.tabstop = 2
vim.opt_local.softtabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.textwidth = 80
vim.opt_local.spell = true

-- t/c wrap prose, q enables gq, j joins comment leaders, n honours
-- formatlistpat, l leaves already-long lines alone. Deliberately no 'a'
-- (reformat-as-you-type) and no 'w' (trailing space continues paragraph) —
-- both fight the treesitter formatter below.
vim.opt_local.formatoptions = "tcqjnl"

-- Repeat the blockquote marker when wrapping.
vim.opt_local.comments = "n:>"

-- Bullets and ordered items, optionally blockquoted, optionally a checkbox.
vim.opt_local.formatlistpat =
  [[^\s*\%(>\s*\)*\%([-*+]\|\d\+[.)]\)\s\+\%(\[[ xX~/-]\]\s\+\)\?]]

vim.opt_local.formatexpr = "v:lua.require'md_format'.formatexpr()"

vim.keymap.set("n", "gw", function()
  vim.o.operatorfunc = "v:lua.require'md_format'.opfunc"
  return "g@"
end, { buffer = true, expr = true, desc = "Format (treesitter-aware)" })

vim.keymap.set(
  "x",
  "gw",
  "<cmd>lua require('md_format').visual()<cr>",
  { buffer = true, desc = "Format (treesitter-aware)" }
)

vim.keymap.set(
  { "n", "x" },
  "<leader>l",
  "<cmd>VimwikiToggleListItem<cr>",
  { buffer = true, desc = "Toggle list item" }
)
