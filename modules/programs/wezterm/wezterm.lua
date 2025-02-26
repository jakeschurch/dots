local wezterm = require("wezterm")
local act = wezterm.action

wezterm.add_to_config_reload_watch_list(wezterm.config_dir)


local fonts = {
  "JetBrains Mono",
  "Noto Sans Emoji",
  "Noto Color Emoji",
}

local config = wezterm.config_builder()

config.disable_default_key_bindings = true
config.keys = {
  {
    key = 'u',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      if pane:is_alt_screen_active() then
        -- Send the key press to Neovim
        win:perform_action(act.SendKey { key = 'u', mods = 'ALT' }, pane)
      else
        -- Perform the scroll action in WezTerm
        win:perform_action(act.ScrollByPage(-1), pane)
      end
    end),
  },

  -- Scroll down by one page when Neovim is not active
  {
    key = 'd',
    mods = 'ALT',
    action = wezterm.action_callback(function(win, pane)
      if pane:is_alt_screen_active() then
        -- Send the key press to Neovim
        win:perform_action(act.SendKey { key = 'd', mods = 'ALT' }, pane)
      else
        -- Perform the scroll action in WezTerm
        win:perform_action(act.ScrollByPage(1), pane)
      end
    end),
  },

  {
    key = '/',
    mods = 'ALT',
    action = act.Search({ CaseInSensitiveString = '' }),
  },
  { key = 'n', mods = 'ALT',       action = act.CopyMode 'NextMatch' },
  { key = 'n', mods = 'ALT|SHIFT', action = act.CopyMode 'PriorMatch' },

  {
    key = "r",
    mods = "ALT",
    action = act({ RotatePanes = "Clockwise" }),
  },
  {
    key = "y",
    mods = "ALT",
    action = act({ CopyTo = "ClipboardAndPrimarySelection" }),
  },
  {
    key = "p",
    mods = "ALT",
    action = act({ PasteFrom = "Clipboard" }),
  },
  {
    key = "Enter",
    mods = "ALT|SHIFT",
    action = act({
      SplitHorizontal = { domain = "CurrentPaneDomain" },
    }),
  },
  {
    key = "Enter",
    mods = "ALT",
    action = act({
      SplitVertical = { domain = "CurrentPaneDomain" },
    }),
  },
  { key = "+", mods = "ALT", action = act.IncreaseFontSize },
  { key = "-", mods = "ALT", action = act.DecreaseFontSize },
  {
    key = "t",
    mods = "ALT",
    action = act({ SpawnTab = "CurrentPaneDomain" }),
  },
  {
    key = "q",
    mods = "ALT",
    action = act({ CloseCurrentPane = { confirm = true } }),
  },
  {
    key = "n",
    mods = "ALT",
    action = act({ ActivateTabRelative = 1 }),
  },
  {
    key = "n",
    mods = "ALT | SHIFT",
    action = act({ ActivateTabRelative = -1 }),
  },

  {
    key = "h",
    mods = "ALT",
    action = act({ ActivatePaneDirection = "Left" }),
  },
  {
    key = "j",
    mods = "ALT",
    action = act({ ActivatePaneDirection = "Down" }),
  },
  {
    key = "k",
    mods = "ALT",
    action = act({ ActivatePaneDirection = "Up" }),
  },
  {
    key = "l",
    mods = "ALT",
    action = act({ ActivatePaneDirection = "Right" }),
  },

  { key = "1", mods = "ALT", action = act({ ActivateTab = 0 }) },
  { key = "2", mods = "ALT", action = act({ ActivateTab = 1 }) },
  { key = "3", mods = "ALT", action = act({ ActivateTab = 2 }) },
  { key = "4", mods = "ALT", action = act({ ActivateTab = 3 }) },
  { key = "5", mods = "ALT", action = act({ ActivateTab = 4 }) },
  { key = "6", mods = "ALT", action = act({ ActivateTab = 5 }) },
  { key = "7", mods = "ALT", action = act({ ActivateTab = 6 }) },
  { key = "8", mods = "ALT", action = act({ ActivateTab = 7 }) },
  { key = "9", mods = "ALT", action = act({ ActivateTab = 8 }) },

  -- Resize pane to the left
  {
    key = 'h',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Left', 5 },
  },
  -- Resize pane to the right
  {
    key = 'l',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Right', 5 },
  },
  -- Resize pane upwards
  {
    key = 'k',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Up', 5 },
  },
  -- Resize pane downwards
  {
    key = 'j',
    mods = 'ALT|SHIFT',
    action = act.AdjustPaneSize { 'Down', 5 },
  },
}

config.default_cwd = os.getenv('HOME') .. '/Projects/work'
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.show_close_tab_button_in_tabs = false
config.color_scheme = "Gruvbox dark, soft (base16)"
config.freetype_load_target = "Light"
config.font_shaper = "Harfbuzz"
config.font = wezterm.font_with_fallback(fonts)
config.font_size = 14.0
config.max_fps = 165

config.dpi = 96
config.audible_bell = "Disabled"
config.check_for_updates = false
config.force_reverse_video_cursor = true
config.front_end = "OpenGL"
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.harfbuzz_features = { "calt=0" }
config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 4,
}
config.use_resize_increments = true
config.animation_fps = 60
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.default_cursor_style = "SteadyBlock"
config.quick_select_patterns = {
  -- match things that look like sha1 hashes
  -- (this is actually one of the default patterns)
  "[0-9a-f]{6,40}",
  -- emails
  "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
}
config.mouse_bindings = {
  {
    event = {
      Down = {
        streak = 1,
        button = "Left",
      },
    },
    mods = "NONE",
    action = act({ SelectTextAtMouseCursor = "Cell" }),
  },

  {
    event = {
      Down = {
        streak = 2,
        button = "Left",
      },
    },
    mods = "NONE",
    action = act({ SelectTextAtMouseCursor = "Word" }),
  },

  {
    event = {
      Down = {
        streak = 3,
        button = "Left",
      },
    },
    mods = "NONE",
    action = act({ SelectTextAtMouseCursor = "Line" }),
  },

  {
    event = {
      Up = {
        streak = 1,
        button = "Left",
      },
    },
    mods = "NONE",
    action = act({
      CompleteSelectionOrOpenLinkAtMouseCursor = "PrimarySelection",
    }),
  },

  {
    event = {
      Down = {
        streak = 1,
        button = "Middle",
      },
    },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },

  {
    event = {
      Down = {
        streak = 1,
        button = "Right",
      },
    },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}

-- config.set_environment_variables = {
--   TERMINFO_DIRS = '/Users/jake/.nix-profile/share/terminfo',
-- }
config.term = "wezterm"

return config
