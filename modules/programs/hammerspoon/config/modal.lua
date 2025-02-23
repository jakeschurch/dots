local Modal = {}

-- Create a new modal instance
function Modal.new(hs, menuKey, bindings, modifier)
  local self = setmetatable({}, { __index = Modal })

  self.hs = hs
  self.menuKey = menuKey
  self.bindings = bindings
  self.modifier = modifier or "cmd" -- Default modifier is "cmd"
  self.active = false
  self.modalHotkeys = {} -- Store modal hotkeys for cleanup

  return self
end

-- Enable the modal
function Modal:enable()
  if self.active then
    self:disable()
    return
  end
  self.active = true

  -- Add the modal keybindings
  for _, binding in ipairs(self.bindings) do
    if type(binding.key) == "string" or type(binding.key) == "number" then
      local hotkey = self.hs.hotkey.bind({}, binding.key, function()
        self.hs.alert.closeAll()
        binding.action()
        self:disable() -- Clean up after action
      end)
      table.insert(self.modalHotkeys, hotkey) -- Store for cleanup
    else
      self.hs.alert.show("Invalid key in binding: " .. tostring(binding.key))
    end
  end

  -- Add an escape key to exit the modal
  local escapeHotkey = self.hs.hotkey.bind({}, "escape", function()
    self.hs.alert.closeAll()
    self:disable() -- Clean up after escape
  end, nil, nil, "modalEscape")
  table.insert(self.modalHotkeys, escapeHotkey) -- Store for cleanup

  -- Show a visual indicator of the modal menu with descriptions
  local menuText = {}
  for _, binding in ipairs(self.bindings) do
    table.insert(menuText, binding.key .. ": " .. binding.description)
  end
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
