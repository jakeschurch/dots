local M = {}

M.keys = {
  o = {
    description = "Open window",
    keys = {
      s = {
        description = "Slack",
        action = function()
          hs.application.launchOrFocus("Slack")
        end,
      },
      a = {
        description = "Around",
        action = function()
          hs.application.launchOrFocus("around")
        end,
      },
      n = {
        description = "Notion",
        action = function()
          hs.application.launchOrFocus("notion")
        end,
      },
      c = {
        description = "Chrome",
        action = function()
          hs.application.launchOrFocus("Google Chrome")
        end,
      },

      ["return"] = {
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
      [","] = {
        description = "Notion Calendar",
        action = function()
          hs.application.launchOrFocus("Notion Calendar")
        end,
      },
      e = {
        description = "Google Chrome",
        action = function()
          hs.application.launchOrFocus("Google Chrome")
        end,
      },
      h = {
        description = "hs console",
        action = function()
          hs.application.launchOrFocus("Hammerspoon")
        end,
      },
      z = {
        description = "zoom",
        action = function()
          hs.application.launchOrFocus("zoom.us")
        end,
      },
      m = {
        description = "Spotify",
        action = function()
          hs.application.launchOrFocus("Spotify")
        end,
      },
    },
  },
}

return M
