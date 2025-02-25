require("windows")
require("keymaps")

local leaderKey = "cmd"

hs.window.animationDuration = 0
hs.grid.setGrid("6x6")
hs.grid.setMargins("0x0")

-- hs.hotkey.bind({ "cmd" }, "g", hs.grid.show)

-- Function to list all open window names
local function listOpenWindows()
  local windows = hs.window.allWindows() -- Get all open windows
  for i, win in ipairs(windows) do
    local appName = win:application():name() -- Get the application name
    local windowTitle = win:title() -- Get the window title
    print(string.format("Window %d: %s - %s", i, appName, windowTitle))
  end
end

hs.hotkey.bind({ leaderKey }, "w", function()
  listOpenWindows()
end)

hs.hotkey.bind({ leaderKey }, "r", function()
  hs.reload()
  hs.alert.show("hs config reloaded")
end)
