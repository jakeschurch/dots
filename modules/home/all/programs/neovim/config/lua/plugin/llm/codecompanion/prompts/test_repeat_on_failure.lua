local constants = require("codecompanion.config").constants

return {
  {
    name = "Repeat On Failure",
    role = constants.USER_ROLE,
    opts = { auto_submit = true },
    -- Scope this prompt to only run when the cmd_runner tool is active
    condition = function()
      return _G.codecompanion_current_tool == "cmd_runner"
    end,
    -- Repeat until the tests pass, as indicated by the testing flag
    repeat_until = function(chat)
      return chat.tools.flags.testing == true
    end,
    content = "The tests have failed. Can you edit the buffer and run the test suite again?",
  },
}
