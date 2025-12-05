return {
  description = "List git files",
  ---@param chat CodeCompanion.Chat
  callback = function(chat)
    local handle = io.popen("git ls-files")
    if handle ~= nil then
      local result = handle:read("*a")
      handle:close()
      chat:add_reference({ content = result }, "git", "<git_files>")
      return vim.notify("Git files added to the chat.")
    else
      return vim.notify(
        "No git files available",
        vim.log.levels.INFO,
        { title = "CodeCompanion" }
      )
    end
  end,
  opts = {
    contains_code = false,
  },
}
