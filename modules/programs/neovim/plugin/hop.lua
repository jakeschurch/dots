local remap = vim.api.nvim_set_keymap
remap("n", "s", "<cmd>lua require'hop'.hint_char2()<cr>", {})
remap("n", "S", "<cmd>lua require'hop'.hint_char2()<cr>", {})
require("hop").setup()
