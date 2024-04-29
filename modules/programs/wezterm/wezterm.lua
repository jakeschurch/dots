local wezterm = require("wezterm")
wezterm.add_to_config_reload_watch_list(wezterm.config_dir)

local fonts = {
	"JetBrains Mono",
	"Noto Sans Emoji",
	"Noto Color Emoji",
}

return {

	keys = {
		{ key = "r", mods = "ALT|SHIFT", action = wezterm.action({ RotatePanes = "CounterClockwise" }) },
		{ key = "r", mods = "ALT", action = wezterm.action({ RotatePanes = "Clockwise" }) },
		{ key = "y", mods = "ALT", action = wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }) },
		{ key = "p", mods = "ALT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
		{
			key = "Enter",
			mods = "ALT|SHIFT",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
		{
			key = "Enter",
			mods = "ALT",
			action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }),
		},
		{ key = "+", mods = "ALT", action = wezterm.action.IncreaseFontSize },
		{ key = "-", mods = "ALT", action = wezterm.action.DecreaseFontSize },
		{ key = "t", mods = "ALT", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "Space", mods = "ALT|SHIFT", action = "QuickSelect" },
		{ key = "q", mods = "ALT", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
		{ key = "n", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "n", mods = "ALT | SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },

		{ key = "h", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l", mods = "ALT", action = wezterm.action({ ActivatePaneDirection = "Right" }) },

		{ key = "1", mods = "ALT", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "ALT", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "ALT", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "ALT", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "7", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "8", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "9", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) },
	},

	color_scheme = "Gruvbox dark, soft (base16)",
	font = wezterm.font_with_fallback(fonts),
	font_size = 14.0,
	dpi = 96,
	audible_bell = "Disabled",
	check_for_updates = false,
	force_reverse_video_cursor = true,
	front_end = "OpenGL",
	tab_bar_at_bottom = true,
	hide_tab_bar_if_only_one_tab = true,
	use_fancy_tab_bar = true,
	window_padding = {
		left = 8,
		right = 8,
		top = 6,
		bottom = 4,
	},
	use_resize_increments = true,
	animation_fps = 60,
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	default_cursor_style = "SteadyBlock",
	quick_select_patterns = {
		-- match things that look like sha1 hashes
		-- (this is actually one of the default patterns)
		"[0-9a-f]{6,40}",
		-- emails
		"\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
	},
	mouse_bindings = {
		{
			event = {
				Down = {
					streak = 1,
					button = "Left",
				},
			},
			mods = "NONE",
			action = wezterm.action({ SelectTextAtMouseCursor = "Cell" }),
		},

		{
			event = {
				Down = {
					streak = 2,
					button = "Left",
				},
			},
			mods = "NONE",
			action = wezterm.action({ SelectTextAtMouseCursor = "Word" }),
		},

		{
			event = {
				Down = {
					streak = 3,
					button = "Left",
				},
			},
			mods = "NONE",
			action = wezterm.action({ SelectTextAtMouseCursor = "Line" }),
		},

		{
			event = {
				Up = {
					streak = 1,
					button = "Left",
				},
			},
			mods = "NONE",
			action = wezterm.action({ CompleteSelectionOrOpenLinkAtMouseCursor = "PrimarySelection" }),
		},

		{
			event = {
				Down = {
					streak = 1,
					button = "Middle",
				},
			},
			mods = "NONE",
			action = wezterm.action.PasteFrom("Clipboard"),
		},

		{
			event = {
				Down = {
					streak = 1,
					button = "Right",
				},
			},
			mods = "NONE",
			action = wezterm.action.PasteFrom("Clipboard"),
		},
	},
}
