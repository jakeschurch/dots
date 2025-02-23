local M = {
  {
    key = "a",
    description = "Around",
    action = function()
      hs.application.launchOrFocus("around")
    end,
  },
  {
    key = "n",
    description = "Notion",
    action = function()
      hs.application.launchOrFocus("notion")
    end,
  },
  {
    key = "c",
    description = "Chrome",
    action = function()
      hs.application.launchOrFocus("Google Chrome")
    end,
  },
  {
    key = "return",
    description = "Terminal",
    action = function()
      local app = hs.application.get("wezterm")
      if app then
        app:activate()
      else
        local weztermPath = hs.execute("which wezterm-gui"):gsub("%s+", "")
        hs.execute(weztermPath)
      end
    end,
  },
  {
    key = "s",
    description = "Slack",
    action = function()
      hs.application.launchOrFocus("Slack")
    end,
  },
  {
    key = "z",
    description = "Zoom",
    action = function()
      hs.application.launchOrFocus("zoom.us")
    end,
  },
  {
    key = "w",
    description = "WhatsApp",
    action = function()
      hs.application.launchOrFocus("whatsapp")
    end,
  },
  {
    key = "m",
    description = "Spotify",
    action = function()
      hs.application.launchOrFocus("spotify")
    end,
  },
  {
    key = ",",
    description = "Notion Calendar",
    action = function()
      hs.application.launchOrFocus("notion calendar")
    end,
  },
}

return M
