-- window movements
vim.keymap.set("n", "<C-q>", "<C-w>q")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- better command defaults
vim.keymap.set("n", "!", ":!")

-- save whole line in buffer
vim.keymap.set("n", "Y", "^y$")

-- quick save
vim.keymap.set("n", "W", ":wa!<cr>")

-- change pwd to file dir
vim.keymap.set("n", "<leader>hf", ":lcd %:p:h<cr>")

vim.keymap.set("n", "J", "mzJ`z")

-- pgdn
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- pgup
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.cmd([[
cnoremap %s/ %s/\v
cnoremap s/ s/\v

cnoreabbrev c G c
cnoreabbrev a G add %
]])
