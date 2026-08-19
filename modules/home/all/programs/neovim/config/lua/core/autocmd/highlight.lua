local group = vim.api.nvim_create_augroup("highlight", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    pcall(vim.hl.hl_op, { on_visual = true })
  end,
  desc = "Flash the yanked region",
})

local keywords = {
  myTodo = [[\%(TODO\|FIXME\|OPTIMIZE\|XXX\)[Ss:]\?]],
  Question = [[\%(BUG\|NOTE\|IDEA\|INFO\|TEMP\|REVIEW\|DONE\)[Ss:]\?]],
}

local function set_todo_highlight()
  local palette = require("lib.palette")
  vim.api.nvim_set_hl(0, "myTodo", {
    bold = true,
    italic = true,
    bg = palette.bg1,
    fg = palette.yellow,
  })
end

set_todo_highlight()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_todo_highlight,
  desc = "Keep the TODO highlight across colourscheme changes",
})

vim.api.nvim_create_autocmd({ "WinEnter", "VimEnter" }, {
  group = group,
  callback = function()
    for hl, pattern in pairs(keywords) do
      pcall(vim.fn.matchadd, hl, pattern, 10)
    end
  end,
  desc = "Highlight TODO/NOTE keywords in every window",
})
