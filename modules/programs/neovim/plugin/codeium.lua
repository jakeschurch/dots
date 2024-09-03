vim.g.codeium_enabled = true

vim.keymap.set("i", "<TAB>", function()
  return vim.fn["codeium#Accept"]()
end, { expr = true, silent = true })

vim.keymap.set("i", "<M-]>", function()
  return vim.fn["codeium#CycleCompletions"](1)
end, { expr = true, silent = true })

vim.keymap.set("i", "<M-[>", function()
  return vim.fn["codeium#CycleCompletions"](-1)
end, { expr = true, silent = true })
