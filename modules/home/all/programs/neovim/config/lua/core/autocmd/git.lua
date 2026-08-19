vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("git", { clear = true }),
  pattern = "gitcommit",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
  desc = "Wrap and spell-check commit messages",
})
