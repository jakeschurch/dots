require("otter").setup()

-- FileType patterns match the filetype name, not the file name.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown" },
  callback = function()
    require("otter").activate()
  end,
})

-- Loaded after VimEnter, so a markdown file opened from the command line has
-- already fired its FileType event.
if vim.bo.filetype == "markdown" then
  require("otter").activate()
end
