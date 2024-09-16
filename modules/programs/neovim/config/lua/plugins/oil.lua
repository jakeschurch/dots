vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("oil").setup({
  columns = {
    "icon",
    "size",
    "mtime",
  },
  view_options = {
    show_hidden = true,
  },
})
