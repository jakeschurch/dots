require("windows")
require("spaces")
require("modalBindings")

local MOD = "cmd"

hs.window.animationDuration = 0
hs.grid.setGrid("6x6")
hs.grid.setMargins("0x0")

hs.hotkey.bind({ "cmd" }, "g", hs.grid.show)

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
