require("otter").setup()

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*.md" },
  callback = function()
    require("otter").activate()
  end,
})
