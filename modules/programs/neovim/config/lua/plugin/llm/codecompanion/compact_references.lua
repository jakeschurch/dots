local codecompanion = require("codecompanion")
local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "CodeCompanionChatOpened",
  group = group,
  callback = function()
    vim.wo.number = false
    vim.wo.relativenumber = false
  end,
})

local function compact_reference(messages)
  local refs = {}
  local result = {}

  -- First loop to find last occurrence of each reference
  for i, msg in ipairs(messages) do
    if msg.opts and msg.opts.reference then
      refs[msg.opts.reference] = i
    end
  end

  -- Second loop to keep messages with unique references
  for i, msg in ipairs(messages) do
    local ref = msg.opts and msg.opts.reference
    if not ref or refs[ref] == i then
      table.insert(result, msg)
    end
  end

  return result
end
vim.api.nvim_create_autocmd({ "User" }, {
  pattern = "CodeCompanionRequestFinished",
  group = group,
  callback = function(request)
    if request.data.strategy ~= "chat" then
      return
    end
    local current_chat = codecompanion.last_chat()
    if not current_chat then
      return
    end
    local config = require("codecompanion.config")
    local add_reference =
      require("plugin.llm.codecompanion.utils.add_reference")

    add_reference(current_chat, {
      role = config.constants.USER_ROLE,
      content = string.format(
        "# Environment\n- Current Time: %s\n",
        os.date("%c")
      ),
    }, "system_prompt", "environment")
    current_chat.messages = compact_reference(current_chat.messages)
  end,
})
