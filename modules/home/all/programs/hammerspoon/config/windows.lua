function hs.screen.get(screen_name)
  local allScreens = hs.screen.allScreens()
  for _, screen in ipairs(allScreens) do
    if screen:name() == screen_name then
      return screen
    end
  end
end

function hs.screen.withFocusedWindow(func)
  local win = hs.window.focusedWindow()
  if win == nil then
    return
  end
  return func(win)
end

-- Returns the width of the current screen size
-- isFullscreen = false removes the toolbar
-- and dock sizes
function hs.screen.minWidth(screen, isFullscreen)
  local screen_frame = screen:frame()
  if isFullscreen then
    screen_frame = screen:fullFrame()
  end
  return screen_frame.w
end

--
-- Returns the Height of the current screen size
-- isFullscreen = false removes the toolbar
-- and dock sizes
function hs.screen.minHeight(screen, isFullscreen)
  local screen_frame = screen:frame()
  if isFullscreen then
    screen_frame = screen:fullFrame()
  end
  return screen_frame.h
end

function hs.screen.minX(refScreen)
  return refScreen:frame().x
end

function hs.screen.minY(refScreen)
  return refScreen:frame().y
end

function hs.screen.almostMinX(refScreen)
  local min_x = refScreen:frame().x
    + (
      ((refScreen:frame().w - hs.screen.minWidth(refScreen)) / 2)
      - ((refScreen:frame().w - hs.screen.minWidth()) / 4)
    )
  return min_x
end

function hs.screen.almostMinY(refScreen)
  local min_y = refScreen:frame().y
    + (
      ((refScreen:frame().h - hs.screen.minHeight()) / 2)
      - ((refScreen:frame().h - hs.screen.minHeight()) / 4)
    )
  return min_y
end

-- Returns the frame of the available screen
-- considering the context of refScreen
-- isFullscreen = false removes the toolbar
-- and dock sizes
function hs.screen.minFrame(refScreen, isFullscreen)
  local result = {
    x = hs.screen.minX(refScreen),
    y = hs.screen.minY(refScreen),
    w = hs.screen.minWidth(refScreen, isFullscreen),
    h = hs.screen.minHeight(refScreen, isFullscreen),
  }
  return result
end

hs.window.move = {
  -- +-----------------+
  -- |        |        |
  -- |        |  HERE  |
  -- |        |        |
  -- +-----------------+
  right = function()
    return hs.screen.withFocusedWindow(function(win)
      local minFrame = hs.screen.minFrame(win:screen(), false)
      minFrame.x = minFrame.x + (minFrame.w / 2)
      minFrame.w = minFrame.w / 2
      win:setFrame(minFrame)
    end)
  end,

  -- +-----------------+
  -- |        |        |
  -- |  HERE  |        |
  -- |        |        |
  -- +-----------------+
  left = function()
    return hs.screen.withFocusedWindow(function(win)
      local minFrame = hs.screen.minFrame(win:screen(), false)
      minFrame.w = minFrame.w / 2
      win:setFrame(minFrame)
    end)
  end,

  -- +-----------------+
  -- |      HERE       |
  -- +-----------------+
  -- |                 |
  -- +-----------------+
  up = function()
    return hs.screen.withFocusedWindow(function(win)
      local minFrame = hs.screen.minFrame(win:screen(), false)
      minFrame.h = minFrame.h / 2
      win:setFrame(minFrame)
    end)
  end,

  -- +-----------------+
  -- |                 |
  -- +-----------------+
  -- |      HERE       |
  -- +-----------------+
  down = function()
    return hs.screen.withFocusedWindow(function(win)
      local minFrame = hs.screen.minFrame(win:screen(), false)
      minFrame.y = minFrame.y + minFrame.h / 2
      minFrame.h = minFrame.h / 2
      win:setFrame(minFrame)
    end)
  end,
}

hs.window.focus = {

  north = function()
    return hs.screen.withFocusedWindow(function(win)
      return win.focusWindowNorth(nil, false, true)
    end)
  end,

  east = function()
    return hs.screen.withFocusedWindow(function(win)
      return win.focusWindowEast(nil, false, true)
    end)
  end,

  south = function()
    return hs.screen.withFocusedWindow(function(win)
      return win.focusWindowSouth(nil, false, true)
    end)
  end,

  west = function()
    return hs.screen.withFocusedWindow(function(win)
      return win.focusWindowWest(nil, false, true)
    end)
  end,
}

local originalWindowFrames = {}

hs.window.action = {
  move = function(screenNum)
    return hs.screen.withFocusedWindow(function(win)
      win:moveToScreen(hs.screen.find(screenNum))
    end)
  end,

  toggleFullscreen = function()
    return hs.screen.withFocusedWindow(function(win)
      if not win then
        return
      end

      local winID = win:id()

      -- If this window has been saved (i.e., it was toggled before)
      if originalWindowFrames[winID] then
        -- If it was fullscreen, restore the original frame
        local originalFrame = originalWindowFrames[winID]
        win:setFrame(originalFrame)
        originalWindowFrames[winID] = nil
      else
        -- Save the original frame and set the window to fullscreen
        originalWindowFrames[winID] = win:frame()
        local screenFrame = win:screen():frame()
        win:setFrame(screenFrame)
      end
    end)
  end,

  close = function()
    return hs.screen.withFocusedWindow(function(win)
      win:close()
    end)
  end,

  switch = {
    next = function()
      hs.window.switcher.nextWindow()
    end,
    prev = function()
      hs.window.switcher.prevWindow()
    end,
  },
}

function hs.window.fullscreenWidth(win)
  local minFrame = hs.screen.minFrame(win:screen(), false)
  win:setFrame({
    x = hs.screen.almostMinX(win:screen()),
    y = hs.screen.minY(win:screen()),
    w = minFrame.w,
    h = minFrame.h,
  })
end

function focus(callback)
  local win = hs.window.focusedWindow()
  if win == nil then
    return
  end

  return callback(win)
end

hs.hotkey.bind({ "cmd" }, "f", hs.window.action.toggleFullscreen)
hs.hotkey.bind({ "cmd" }, "l", hs.window.focus.east)
hs.hotkey.bind({ "cmd" }, "j", hs.window.focus.south)
hs.hotkey.bind({ "cmd" }, "k", hs.window.focus.north)
hs.hotkey.bind({ "cmd" }, "h", hs.window.focus.west)
hs.hotkey.bind({ "cmd" }, "q", hs.window.action.close)

hs.hotkey.bind({ "cmd", "shift" }, "h", hs.window.move.left)
hs.hotkey.bind({ "cmd", "shift" }, "j", hs.window.move.down)
hs.hotkey.bind({ "cmd", "shift" }, "k", hs.window.move.up)
hs.hotkey.bind({ "cmd", "shift" }, "l", hs.window.move.right)

-- hs.hotkey.bind({ "cmd", "shift" }, "<Left>", hs.window.move.left)
-- hs.hotkey.bind({ "cmd", "shift" }, "<Down>", hs.window.move.down)
-- hs.hotkey.bind({ "cmd", "shift" }, "<Up>", hs.window.move.up)
-- hs.hotkey.bind({ "cmd", "shift" }, "<Right>", hs.window.move.right)

hs.hotkey.bind({ "cmd" }, "n", hs.window.action.switch.next)
hs.hotkey.bind({ "cmd" }, "N", hs.window.action.switch.prev)

hs.hotkey.bind({ "cmd" }, "q", hs.window.action.close)
