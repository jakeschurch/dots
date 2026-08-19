vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim", { clear = true }),
  callback = function(ev)
    require("lib.trim").buffer(ev.buf)
  end,
  desc = "Strip trailing and invisible whitespace",
})
