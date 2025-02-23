local utils = require("utils")

local executeCommand = utils.executeCommand
local getSystem = utils.getSystem
local wrap = utils.wrap

local M = {
  {
    key = "l",
    description = "lock screen",
    action = function()
      local commandSet = {
        Linux = wrap(executeCommand("locker.sh")),
        Darwin = wrap(executeCommand("open -a ScreenSaverEngine")),
      }
      return commandSet[getSystem()]()
    end,
  },

  {
    key = "p",
    description = "power off",
    action = function()
      local commandSet = {
        Linux = wrap(executeCommand("sudo poweroff")),
        Darwin = wrap(executeCommand("sudo shutdown -h now")),
      }
      return commandSet[getSystem()]()
    end,
  },

  {
    key = "r",
    description = "reboot",
    action = function()
      local commandSet = {
        Linux = wrap(executeCommand("sudo reboot")),
        Darwin = wrap(executeCommand("sudo shutdown -r now")),
      }
      return commandSet[getSystem()]()
    end,
  },
  {
    key = "s",
    description = "sleep",
    action = function()
      local commandSet = {
        Linux = wrap(executeCommand("systemctl suspend")),
        Darwin = wrap(executeCommand("pmset sleepnow")),
      }
      return commandSet[getSystem()]()
    end,
  },
}

return M
