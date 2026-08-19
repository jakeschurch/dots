-- Paste and automatically re-indent to match current line
vim.keymap.set("n", "p", "p=`]", { noremap = true, silent = true })
vim.keymap.set("n", "P", "P=`[", { noremap = true, silent = true })
