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
    hs.application.launchOrFocus("Arc")
  end,
  [singleKey("return", "terminal")] = function()
    hs.application.launchOrFocus("wezterm")
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
}
hs.hotkey.bind(
  { MOD },
  "o",
  spoon.RecursiveBinder.recursiveBind(appOpenBindings)
)

hs.hotkey.bind({ "cmd" }, "r", function()
  hs.reload()
end)
