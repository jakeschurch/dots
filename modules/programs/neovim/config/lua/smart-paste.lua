-- Paste and automatically re-indent to match current line
vim.api.nvim_set_keymap("n", "p", "p=`]==", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "P", "P=`]==", { noremap = true, silent = true })
