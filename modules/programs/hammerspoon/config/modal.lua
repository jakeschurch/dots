local Modal = {}

-- Create a new modal instance
function Modal.new(hs, menuKey, bindings, modifier)
  local self = setmetatable({}, { __index = Modal })

  self.hs = hs
  self.menuKey = menuKey
  self.bindings = bindings or {}
  self.modifier = modifier or "cmd" -- Default modifier is "cmd"
  self.active = false
  self.modalHotkeys = {} -- Store modal hotkeys for cleanup
  self.inactivityTimer = nil -- Timer to track inactivity

  return self
end

-- Deep merge multiple key binding tables
function Modal.aggregateBindings(...)
  local result = {}

  local function deepMerge(t1, t2)
    for k, v in pairs(t2) do
      if type(v) == "table" and type(t1[k]) == "table" then
        -- Both values are tables, merge recursively
        t1[k] = deepMerge(t1[k], v)
      elseif type(v) == "table" then
        -- If only t2 has a table, copy it
        t1[k] = deepMerge({}, v)
      else
        -- Overwrite scalar values (description, action, etc.)
        t1[k] = v
      end
    end
    return t1
  end

  for _, bindings in ipairs({ ... }) do
    result = deepMerge(result, bindings)
  end

  return result
end

-- Recursive function to build the keybinding display
local function buildBindingDisplay(bindings, prefix)
  local displayText = {}

  for key, binding in pairs(bindings) do
    local fullKey = prefix .. key
    table.insert(displayText, fullKey .. ": " .. (binding.description or ""))

    -- If the binding has sub-keys (a submenu), recursively add them
    if binding.keys then
      local subDisplayText = buildBindingDisplay(binding.keys, fullKey .. " + ")
      for _, subText in ipairs(subDisplayText) do
        table.insert(displayText, subText)
      end
    end
  end

  return displayText
end

-- Enable the modal
function Modal:enable()
  if self.active then
    self:disable()
    return
  end
  self.active = true

  -- Add the modal keybindings
  for key, binding in pairs(self.bindings) do
    if type(key) == "string" or type(key) == "number" then
      -- Handle nested submenus
      if binding.keys then
        local subModal = Modal.new(self.hs, key, binding.keys, self.modifier)
        subModal:bind()

        -- Bind the first key to activate the submodal
        local hotkey = self.hs.hotkey.bind({}, key, function()
          self.hs.alert.closeAll()
          subModal:enable() -- Activate submenu
        end)
        table.insert(self.modalHotkeys, hotkey)
      elseif binding.action then
        -- Handle regular action bindings
        local hotkey = self.hs.hotkey.bind({}, key, function()
          self.hs.alert.closeAll()
          binding.action()
          self:disable() -- Exit after action
        end)
        table.insert(self.modalHotkeys, hotkey)
      end
    else
      self.hs.alert.show("Invalid key in binding: " .. tostring(key))
    end
  end

  -- Escape key to exit modal
  local escapeHotkey = self.hs.hotkey.bind({}, "escape", function()
    self.hs.alert.closeAll()
    self:disable()
  end)
  table.insert(self.modalHotkeys, escapeHotkey)

  -- Display modal menu
  local menuText = buildBindingDisplay(self.bindings, self.modifier .. "+")
  self.hs.alert.show(table.concat(menuText, "\n"))
end

-- Disable the modal and clean up keybindings
function Modal:disable()
  if not self.active then
    return
  end
  self.active = false

  -- Remove the modal keybindings
  for _, hotkey in ipairs(self.modalHotkeys) do
    hotkey:disable() -- Disable the hotkey
  end
  self.modalHotkeys = {} -- Clear the modal hotkeys table
end

-- Reset the inactivity timer
function Modal:resetInactivityTimer()
  -- If the timer exists, stop it
  if self.inactivityTimer then
    self.inactivityTimer:stop()
  end

  -- Create a new timer that will disable the modal after 3 seconds of inactivity
  self.inactivityTimer = hs.timer.doAfter(3, function()
    self:disable() -- Disable the modal after 3 seconds
  end)
end

-- Bind the modal to a hotkey
function Modal:bind()
  if type(self.menuKey) == "string" or type(self.menuKey) == "number" then
    self.hs.hotkey.bind({ self.modifier }, self.menuKey, function()
      self:enable()
    end)
  else
    self.hs.alert.show("Invalid menuKey: " .. tostring(self.menuKey))
  end
end

return Modal
