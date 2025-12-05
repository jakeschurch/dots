local wrap = require("utils").wrap

local M = {}

M.focusScreen = function(screenIndex)
  -- Get all screens and sort them left-to-right
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    return a:frame().x < b:frame().x
  end)

  local screen = screens[screenIndex] -- Ensure index is valid
  if not screen then
    hs.alert.show("Screen " .. screenIndex .. " not found!")
    return
  end

  -- Find windows on the target screen
  local windows = hs.window.orderedWindows()
  local targetWindows = {}

  for _, win in ipairs(windows) do
    if win:screen() == screen then
      table.insert(targetWindows, win)
    end
  end

  if #targetWindows > 0 then
    -- Focus the first window found on the target screen
    targetWindows[1]:focus()
  else
    -- No windows found, move the cursor to the center of the screen
    local frame = screen:frame()
    hs.mouse.absolutePosition({
      x = frame.x + frame.w / 2,
      y = frame.y + frame.h / 2,
    })
  end
end

M.moveWindowToScreen = function(screenIndex)
  local screens = hs.screen.allScreens()
  table.sort(screens, function(a, b)
    return a:frame().x < b:frame().x
  end)

  local screen = screens[screenIndex] -- Ensure valid index
  if not screen then
    hs.alert.show("Screen " .. screenIndex .. " not found!")
    return
  end

  local win = hs.window.focusedWindow()
  if win then
    win:moveToScreen(screen)
    win:focus() -- Ensure focus moves with the window
  else
    hs.alert.show("No focused window to move!")
  end
end

M.keys = (function()
  local binds = {
    shift = {
      description = "Move window",
      keys = {},
    },
  }

  -- Create move window key bindings
  for i = 1, #hs.screen.allScreens() do
    local key = tostring(i)

    binds[key] = {
      description = "Focus screen " .. key,
      action = wrap(M.focusScreen, i),
    }

    binds.shift.keys[key] = {
      description = "Move window " .. key,
      action = wrap(M.moveWindowToScreen, i),
    }
  end

  return binds
end)()

return M
