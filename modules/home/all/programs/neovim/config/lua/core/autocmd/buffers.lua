local group = vim.api.nvim_create_augroup("buffers", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "qf", "help", "man", "lspinfo" },
  callback = function(ev)
    vim.keymap.set(
      "n",
      "q",
      "<cmd>close<cr>",
      { buffer = ev.buf, silent = true }
    )
  end,
  desc = "q closes scratch windows",
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype
    if ft:match("commit") or ft:match("rebase") then
      return
    end

    local line, col = unpack(vim.api.nvim_buf_get_mark(ev.buf, '"'))
    if line > 1 and line <= vim.api.nvim_buf_line_count(ev.buf) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end,
  desc = "Restore the cursor to the last edit",
})
