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
