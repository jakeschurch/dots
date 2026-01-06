local ignored_filetypes = require("utils").ignored_filetypes

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
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""

-- Configure treesitter highlighting via autocmd
vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    -- Skip ignored filetypes
    for _, ft in ipairs(ignored_filetypes) do
      if args.match == ft then
        return
      end
    end
    -- Enable treesitter highlighting if parser exists
    local ok = pcall(vim.treesitter.start, args.buf)
    if not ok then
      return
    end
  end,
})

-- Configure nvim-treesitter-textobjects
require("nvim-treesitter-textobjects").setup({
  select = {
    lookahead = true,
    selection_modes = {
      ["@function.outer"] = "V",
      ["@class.outer"] = "V",
    },
  },
  move = {
    set_jumps = true,
  },
})

-- Textobject keymaps
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

-- Select keymaps
vim.keymap.set({ "x", "o" }, "al", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@loop.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "il", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@loop.inner",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "ab", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@block.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "ib", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@block.inner",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "af", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@function.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "if", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@function.inner",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "ac", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@class.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "x", "o" }, "ic", function()
  require("nvim-treesitter-textobjects.select").select_textobject(
    "@class.inner",
    "textobjects"
  )
end)

-- Move keymaps
vim.keymap.set({ "n", "x", "o" }, "]]", function()
  require("nvim-treesitter-textobjects.move").goto_next_start(
    "@function.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "n", "x", "o" }, "]}", function()
  require("nvim-treesitter-textobjects.move").goto_next_end(
    "@function.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "n", "x", "o" }, "[[", function()
  require("nvim-treesitter-textobjects.move").goto_previous_start(
    "@function.outer",
    "textobjects"
  )
end)
vim.keymap.set({ "n", "x", "o" }, "[{", function()
  require("nvim-treesitter-textobjects.move").goto_previous_end(
    "@function.outer",
    "textobjects"
  )
end)
