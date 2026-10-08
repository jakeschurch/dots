local ignored_filetypes = require("lib.utils").ignored_filetypes

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
  },
  pattern = {
    [".*/templates/.*%.tpl"] = "helm",
    [".*/templates/.*%.ya?ml"] = "helm",
    ["helmfile.*%.ya?ml"] = "helm",
  },
})

require("match-up").setup({
  treesitter = {
    stopline = 500,
  },
})

vim.opt.foldlevel = 99
vim.opt.foldenable = true
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

-- Treesitter highlighting and folds for every filetype with a parser, except
-- ignored ones and files too big to parse comfortably.
local MAX_FILESIZE = 1024 * 1024

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
  callback = function(args)
    if vim.tbl_contains(ignored_filetypes, args.match) then
      return
    end
    local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
    if stat and stat.size > MAX_FILESIZE then
      return
    end
    if
      pcall(vim.treesitter.start, args.buf)
      and vim.api.nvim_get_current_buf() == args.buf
    then
      vim.wo[0][0].foldmethod = "expr"
    end
  end,
})
