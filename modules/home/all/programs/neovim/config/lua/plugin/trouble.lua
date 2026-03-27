vim.keymap.set(
  "n",
  "<leader>d",
  "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
  { silent = true, noremap = true }
)

require("trouble").setup({
  height = 10,
  padding = false,
  auto_close = true,
  auto_preview = false,
})
