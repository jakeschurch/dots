require("copilot").setup({
  enabled = true,
  suggestion = {
    enabled = false, -- instead use through cmp
    auto_trigger = false,
  },
  keymap = {
    accept = false,
  },
  filetypes = {
    markdown = true,
  },
  panel = {
    enabled = false,
  },
})

local cmp = require("cmp")
local copilot = require("copilot.suggestion")
local luasnip = require("luasnip")

local function set_trigger(trigger)
  vim.b.copilot_suggestion_auto_trigger = trigger
  vim.b.copilot_suggestion_hidden = not trigger
end

-- Hide suggestions when the completion menu is open.
cmp.event:on("menu_opened", function()
  if copilot.is_visible() then
    copilot.dismiss()
  end
  set_trigger(false)
end)

-- Disable suggestions when inside a snippet.
cmp.event:on("menu_closed", function()
  set_trigger(not luasnip.expand_or_locally_jumpable())
end)
vim.api.nvim_create_autocmd("User", {
  pattern = { "LuasnipInsertNodeEnter", "LuasnipInsertNodeLeave" },
  callback = function()
    set_trigger(not luasnip.expand_or_locally_jumpable())
  end,
})
