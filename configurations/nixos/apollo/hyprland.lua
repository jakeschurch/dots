-- hyprland.lua — Apollo Hyprland config (Hyprland 0.55+ Lua format)
-- Migrated from hyprlang. See https://wiki.hypr.land/Configuring/Start/

--------------------
---- MONITORS ----
--------------------

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

--------------------
---- AUTOSTART ----
--------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- hyprsunset")
  hl.exec_cmd("uwsm app -- phonto --rand")
  hl.exec_cmd("uwsm app -- noctalia-shell")
  hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard both") -- keep clipboard alive on focus switch
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- Force Hyprland to only use NVIDIA GPU (card1)
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")
hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("WLR_NO_HARDWARE_CURSORS", "1")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
  general = {
    layout = "dwindle",
    gaps_in = 3,
    gaps_out = 10,
    float_gaps = 5,
    border_size = 3,
    resize_on_border = true,
  },

  decoration = {
    rounding = 10,
    dim_inactive = true,
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    force_split = 2, -- always split right
    smart_split = false,
    smart_resizing = false,
    preserve_split = true,
  },

  input = {
    kb_layout = "us",
    numlock_by_default = true,
    repeat_delay = 300,
    repeat_rate = 30,
    follow_mouse = true,
    float_switch_override_focus = 0,
    mouse_refocus = 0,
    sensitivity = 0,
    touchpad = {
      natural_scroll = true,
    },
  },

  misc = {
    force_default_wallpaper = 1,
    disable_hyprland_logo = true,
    vrr = 1,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  layout = {
    single_window_aspect_ratio = "4 3",
  },
})

-- Plugin config
hl.config({
  plugin = {
    -- dynamic_cursors disabled — needs investigation on NVIDIA
    -- dynamic_cursors = {
    --     enabled   = true,
    --     mode      = "rotate",
    --     threshold = 2,
    --     rotate = {
    --         limit            = 4000,
    --         ["function"]     = "linear",
    --         window           = 100,
    --     },
    --     shake = {
    --         enabled   = true,
    --         nearest   = true,
    --         threshold = 2.0,
    --         base      = 1.5,
    --         speed     = 3.0,
    --         influence = 0.0,
    --         limit     = 0.2,
    --         timeout   = 100,
    --         effects   = false,
    --         ipc       = false,
    --     },
    -- },
    -- hyprcursor = {
    --     nearest    = true,
    --     enabled    = true,
    --     resolution = -1,
    --     fallback   = "clientside",
    -- },
    -- hyprbars = {
    --     bar_height            = 30,
    --     bar_title_enabled     = false,
    --     bar_buttons_alignment = "right",
    --     bar_part_of_window    = true,
    --     bar_blur              = true,
    --     bar_padding           = 12,
    --     bar_button_padding    = 10,
    --     on_double_click       = "hyprctl dispatch fullscreen 1",
    -- },
  },
})

-- hyprbars buttons (R → L order) — disabled pending investigation
-- hl.plugin.hyprbars.add_button({ bg_color = "rgb(ff5f56)", size = 15, icon = "", action = "smart-kill" })
-- hl.plugin.hyprbars.add_button({ bg_color = "rgb(ffbd2e)", size = 15, icon = "", action = "hyprctl dispatch movetoworkspacesilent special" })
-- hl.plugin.hyprbars.add_button({ bg_color = "rgb(27c93f)", size = 15, icon = "", action = "hyprctl dispatch fullscreen 1" })

---------------------
---- KEYBINDINGS ----
---------------------

local mod = "SUPER"
local ctrl = "CTRL"

-- Launcher / terminal / clipboard / files
hl.bind(
  mod .. " + space",
  hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle")
)
hl.bind(mod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mod .. " + return", hl.dsp.exec_cmd("wezterm"))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + V", hl.dsp.exec_cmd("cliphist-pick"))

-- Screenshots
hl.bind(mod .. " + S", hl.dsp.exec_cmd("hyprshot -m region"))
hl.bind(
  mod .. " + SHIFT + S",
  hl.dsp.exec_cmd("hyprshot -m region --clipboard-only")
)

-- Color picker (auto-copy + notify) — Super+C consumed by xremap for copy
hl.bind(
  mod .. " + SHIFT + C",
  hl.dsp.exec_cmd(
    "hyprpicker -a && notify-send '🎨 Color copied' \"$(wl-paste)\""
  )
)

-- OCR screenshot
hl.bind(mod .. " + O", hl.dsp.exec_cmd("ocr-shot"))

-- Focus toggle (stash other windows → single window gets 4:3 aspect)
hl.bind(mod .. " + F", hl.dsp.exec_cmd("hypr-focus-toggle"))
-- Fullscreen
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen(1))

-- Special workspace (scratchpad / magic)
hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.move({ workspace = "+0" }))

-- Reload + cycle wallpaper
hl.bind(
  mod .. " + SHIFT + R",
  hl.dsp.exec_cmd(
    "hyprctl reload && pkill phonto; phonto --rand & notify-send 'hyprland reloaded 👍'"
  )
)

-- Workspace navigation (ctrl due to keyd remappings)
hl.bind(ctrl .. " + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(ctrl .. " + right", hl.dsp.focus({ workspace = "e+1" }))

-- Focus + move windows with hjkl
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(directions) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Switch workspaces / move windows 1–9
for i = 1, 9 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Audio
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")
)
hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")
)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

-- Hyprsunset: temperature + gamma (repeating on hold)
hl.bind(
  mod .. " + XF86MonBrightnessDown",
  hl.dsp.exec_cmd("hyprctl hyprsunset temperature -250"),
  { repeating = true }
)
hl.bind(
  mod .. " + XF86MonBrightnessUp",
  hl.dsp.exec_cmd("hyprctl hyprsunset temperature +250"),
  { repeating = true }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10"),
  { repeating = true }
)
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10"),
  { repeating = true }
)

-- Drag / resize with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---- RESIZE SUBMAP ----
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", "reset", function()
  hl.bind(
    "h",
    hl.dsp.window.resize({ x = -85, y = 0, relative = true }),
    { repeating = true }
  )
  hl.bind(
    "j",
    hl.dsp.window.resize({ x = 0, y = 85, relative = true }),
    { repeating = true }
  )
  hl.bind(
    "k",
    hl.dsp.window.resize({ x = 0, y = -85, relative = true }),
    { repeating = true }
  )
  hl.bind(
    "l",
    hl.dsp.window.resize({ x = 85, y = 0, relative = true }),
    { repeating = true }
  )
  hl.bind("return", hl.dsp.submap("reset"))
  hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ---- POWER MENU SUBMAP ----
hl.bind(mod .. " + P", hl.dsp.submap("powermenu"))
hl.define_submap("powermenu", "reset", function()
  -- helper: fire cmd then exit submap
  local function pm(cmd)
    return function()
      hl.dispatch(hl.dsp.exec_cmd(cmd))
      hl.dispatch(hl.dsp.submap("reset"))
    end
  end
  hl.bind("l", pm("hyprlock --immediate")) -- lock
  hl.bind("p", pm("systemctl poweroff")) -- power off
  hl.bind("r", pm("systemctl reboot")) -- reboot
  hl.bind("s", pm("systemctl suspend-then-hibernate")) -- suspend
  hl.bind("return", hl.dsp.submap("reset"))
  hl.bind("escape", hl.dsp.submap("reset"))
end)

--------------------------------
---- WINDOW + WORKSPACE RULES ----
--------------------------------

-- Steam games → DP-1, fullscreen mode 3
hl.window_rule({
  name = "steam-games-monitor",
  match = { class = "^(steam_app_.*)$" },
  monitor = "DP-1",
  fullscreen = true,
})

-- cliphist picker → floating, centered, 800×500
hl.window_rule({
  name = "cliphist-picker",
  match = { class = "^(cliphist-picker)$" },
  float = true,
  size = { 800, 500 },
  center = true,
})

-- Bitwarden → floating, centered, 1200×800
hl.window_rule({
  name = "bitwarden",
  match = { class = "^(Bitwarden)$" },
  float = true,
  size = { 1200, 800 },
  center = true,
})
