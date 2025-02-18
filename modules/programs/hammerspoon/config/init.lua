require("windows")
require("spaces")

local MOD = "cmd"

hs.loadSpoon("RecursiveBinder")
spoon.RecursiveBinder.escapeKey = { {}, "escape" } -- Press escape to abort
local singleKey = spoon.RecursiveBinder.singleKey

hs.window.animationDuration = 0
hs.grid.setGrid("6x6")
hs.grid.setMargins("0x0")

hs.hotkey.bind({ "cmd" }, "g", hs.grid.show)

local function executeCommand(command)
  local output, status, _, _ = hs.execute(command)
  return output, status
end

local function getSystem()
  return executeCommand("uname -s")
end

local function wrap(lambda)
  return function()
    lambda()
  end
end

local powermenuBindings = {
  [singleKey("l", "lockscreen")] = function()
    local commandSet = {
      Linux = wrap(executeCommand("locker.sh")),
      Darwin = wrap(executeCommand("open -a ScreenSaverEngine")),
    }
    return commandSet[getSystem()]()
  end,

  [singleKey("p", "power off")] = function()
    local commandSet = {
      Linux = wrap(executeCommand("sudo poweroff")),
      Darwin = wrap(executeCommand("sudo shutdown -h now")),
    }
    return commandSet[getSystem()]()
  end,

  [singleKey("r", "reboot")] = function()
    local commandSet = {
      Linux = wrap(executeCommand("sudo reboot")),
      Darwin = wrap(executeCommand("sudo shutdown -r now")),
    }
    return commandSet[getSystem()]()
  end,

  [singleKey("s", "sleep")] = function()
    local commandSet = {
      Linux = wrap(executeCommand("systemctl suspend")),
      Darwin = wrap(executeCommand("pmset sleepnow")),
    }
    return commandSet[getSystem()]()
  end,
}

hs.hotkey.bind(
  { MOD },
  "p",
  spoon.RecursiveBinder.recursiveBind(powermenuBindings)
)

local appOpenBindings = {
  [singleKey("a", "around")] = function()
    hs.application.launchOrFocus("around")
  end,
  [singleKey("n", "notion")] = function()
    hs.application.launchOrFocus("notion")
  end,
  [singleKey("c", "browser")] = function()
    hs.application.launchOrFocus("Google Chrome")
  end,
  [singleKey("return", "terminal")] = function()
    local weztermPath = hs.execute("which wezterm"):gsub("%s+", "")
    local app = hs.application.get("wezterm")

    if app then
      app:activate()
    else
      hs.execute(weztermPath)
    end
  end,

  [singleKey("s", "slack")] = function()
    hs.application.launchOrFocus("Slack")
  end,

  [singleKey("z", "zoom")] = function()
    hs.application.launchOrFocus("zoom.us")
  end,

  [singleKey("w", "whatsapp")] = function()
    hs.application.launchOrFocus("whatsapp")
  end,

  [singleKey("m", "spotify")] = function()
    hs.application.launchOrFocus("spotify")
  end,

  [singleKey(",", "notion calendar")] = function()
    hs.application.launchOrFocus("notion calendar")
  end,
}

hs.hotkey.bind(
  { MOD },
  "o",
  spoon.RecursiveBinder.recursiveBind(appOpenBindings)
)

-- Function to list all open window names
local function listOpenWindows()
  local windows = hs.window.allWindows() -- Get all open windows
  for i, win in ipairs(windows) do
    local appName = win:application():name() -- Get the application name
    local windowTitle = win:title() -- Get the window title
    print(string.format("Window %d: %s - %s", i, appName, windowTitle))
  end
end

hs.hotkey.bind({ "cmd" }, "w", function()
  listOpenWindows()
end)

hs.hotkey.bind({ "cmd" }, "r", function()
  hs.alert.show("hs config reloaded")
  hs.reload()
end)
