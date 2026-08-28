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
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
  )
  hl.exec_cmd("uwsm app -- hyprsunset")
  hl.exec_cmd("uwsm app -- phonto --rand")
  hl.exec_cmd("uwsm app -- noctalia-shell")
  hl.exec_cmd("uwsm app -- wl-clip-persist --clipboard both") -- keep clipboard alive on focus switch
  hl.exec_cmd("wl-paste --type text --watch cliphist store")
  hl.exec_cmd("wl-paste --type image --watch cliphist store")
  hl.exec_cmd("claude-workspaces")
end)

-- NOTE: noctalia restart is intentionally NOT wired to "config.reloaded".
-- SUPER+SHIFT+R reloads on every wallpaper cycle; restarting the shell there
-- tears down the bar each time. Refresh noctalia explicitly via SUPER+SHIFT+N
-- (reload-noctalia) after loading a new version. Never touches the session.

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

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
    vrr = 0,
  },

  xwayland = {
    force_zero_scaling = true,
  },

  layout = {
    single_window_aspect_ratio = "4 3",
  },
})

-- Load plugins BEFORE their config block, else every plugin.* key below is
-- "unknown" (a raw lua config replaces the generated hyprland.conf that would
-- otherwise load them). Paths come from the environment (set in hyprland.nix) so
-- no store paths live in this file; a missing/empty var is skipped quietly.
for _, env in ipairs({ "HYPR_PLUGIN_HYPRBARS", "HYPR_PLUGIN_DYNAMIC_CURSORS" }) do
  local so = os.getenv(env)
  if so and #so > 0 then
    hl.plugin.load(so)
  end
end

-- Plugin config
hl.config({
  plugin = {
    -- dynamic_cursors: enabled on NVIDIA; revert if cursor flicker/crashes appear
    dynamic_cursors = {
      enabled = true,
      mode = "rotate",
      threshold = 2,
      rotate = {
        limit = 4000,
        ["function"] = "linear",
        window = 100,
      },
      shake = {
        enabled = true,
        nearest = true,
        threshold = 2.0,
        base = 1.5,
        speed = 3.0,
        influence = 0.0,
        limit = 0.2,
        timeout = 100,
        effects = false,
        ipc = false,
      },
    },
    hyprcursor = {
      nearest = true,
      enabled = true,
      resolution = -1,
      fallback = "clientside",
    },
    hyprbars = {
      bar_height = 30,
      on_double_click = "hyprctl dispatch fullscreen 1",
      bar_title_enabled = false,
      bar_buttons_alignment = "right",
      bar_part_of_window = true,
      bar_blur = true,
      bar_padding = 12,
      bar_button_padding = 10,
    },
  },
})

-- hyprbars buttons (R → L order): close · minimize · fullscreen.
-- Minimize sends to special:MinimizedApps — peek it with SUPER+M, restore the
-- focused window with SUPER+SHIFT+return (see keybindings below).
--
-- Guard: if hyprbars fails to load (e.g. a plugin/compositor version mismatch
-- after a rebuild before relogin), hl.plugin.hyprbars is nil. Calling it raw
-- throws and aborts the rest of this config — so NO keybinds register. Wrap in
-- pcall + nil-check so a dead plugin degrades to "no bars" instead of "no binds".
if hl.plugin.hyprbars then
  pcall(function()
    hl.plugin.hyprbars.add_button({
      bg_color = "rgb(ff5f56)",
      size = 15,
      icon = "",
      action = "smart-kill",
    })
    hl.plugin.hyprbars.add_button({
      bg_color = "rgb(ffbd2e)",
      size = 15,
      icon = "",
      action = "hyprctl dispatch movetoworkspacesilent special:MinimizedApps",
    })
    hl.plugin.hyprbars.add_button({
      bg_color = "rgb(27c93f)",
      size = 15,
      icon = "",
      action = "hyprctl dispatch fullscreen 1",
    })
  end)
end

---------------------
---- KEYBINDINGS ----
---------------------

local mod = "SUPER"
local ctrl = "CTRL"

-----------------------
---- WINDOW HELPERS ----
-----------------------

-- Native replacements for the old hypr-focus-toggle shell script. hl.get_windows
-- queries live state, hl.dispatch fires a dispatcher imperatively, and upvalue
-- tables persist for the compositor's lifetime — no /tmp files or hyprctl shelling.

local function active_window()
  for _, w in ipairs(hl.get_windows({ mapped = true })) do
    if w.active then
      return w
    end
  end
  return nil
end

local function tiled_on(ws)
  local out = {}
  for _, w in ipairs(hl.get_windows({ mapped = true })) do
    if w.workspace and w.workspace.id == ws and not w.floating then
      out[#out + 1] = w
    end
  end
  return out
end

-- `at` is an [x, y] array; guard for a {x=, y=} table just in case.
local function win_x(w)
  local a = w.at
  return a[1] or a.x or 0
end
local function win_y(w)
  local a = w.at
  return a[2] or a.y or 0
end
-- `size` is a [w, h] array; same table guard.
local function win_w(w)
  local s = w.size
  return s[1] or s.x or 0
end
local function win_h(w)
  local s = w.size
  return s[2] or s.y or 0
end

-- Focus mode: hide every other tiled window on the workspace so the kept one
-- gets the single-window 4:3 aspect. The old script restored windows in
-- clients-array (creation) order, so dwindle rebuilt the tree scrambled. Here we
-- record each window's original order AND pixel size on enter; on exit we empty
-- the workspace (stash the anchor too), re-insert every window in that order
-- (force_split = 2 splits each right of the previous, so the row rebuilds in the
-- same order — anchor back in its slot), then resize each back to its recorded
-- size so dwindle doesn't reset everything to even 0.5 splits.
local focus_state = {} -- ws id -> ordered list of { addr, w, h }

local function focus_toggle()
  local aw = active_window()
  if not aw then
    return
  end
  local ws = aw.workspace.id
  local addr = aw.address

  -- Maximized/fullscreen (e.g. from SUPER+SHIFT+F): just clear it.
  if aw.fullscreen ~= 0 then
    hl.dispatch(hl.dsp.window.fullscreen(aw.fullscreen))
    return
  end

  local stash = "special:focusstash-" .. ws

  if focus_state[ws] then
    -- Empty the workspace, then re-insert in recorded order to rebuild the tree.
    hl.dispatch(hl.dsp.window.move({ workspace = stash, window = "address:" .. addr }))
    for _, it in ipairs(focus_state[ws]) do
      hl.dispatch(hl.dsp.window.move({ workspace = ws, window = "address:" .. it.addr }))
    end
    -- Then restore each window's original size (dwindle would otherwise reset the
    -- whole workspace to even 0.5 splits).
    for _, it in ipairs(focus_state[ws]) do
      hl.dispatch(hl.dsp.focus({ window = "address:" .. it.addr }))
      hl.dispatch(hl.dsp.window.resize({ exact = true, x = it.w, y = it.h }))
    end
    hl.dispatch(hl.dsp.focus({ window = "address:" .. addr }))
    focus_state[ws] = nil
  else
    local wins = tiled_on(ws)
    table.sort(wins, function(x, y)
      if win_y(x) == win_y(y) then
        return win_x(x) < win_x(y)
      end
      return win_y(x) < win_y(y)
    end)
    local state = {}
    for _, w in ipairs(wins) do
      state[#state + 1] = { addr = w.address, w = win_w(w), h = win_h(w) }
    end
    focus_state[ws] = state
    for _, w in ipairs(wins) do
      if w.address ~= addr then
        hl.dispatch(hl.dsp.window.move({ workspace = stash, window = "address:" .. w.address }))
      end
    end
    hl.dispatch(hl.dsp.focus({ window = "address:" .. addr }))
  end
end

-- Equalize: make every tiled window on the focused monitor the same size.
-- dwindle has no native balance, but force_split = 2 lays windows out in a
-- horizontal row, so setting each to width = usable/N at full height evens them.
local function equalize()
  local mon
  for _, m in ipairs(hl.get_monitors()) do
    if m.focused then
      mon = m
    end
  end
  if not mon or not mon.active_workspace then
    return
  end
  local wins = tiled_on(mon.active_workspace.id)
  local n = #wins
  if n < 2 then
    return
  end

  local gaps_out, gaps_in = 10, 3
  local r = mon.reserved or { 0, 0, 0, 0 } -- [left, top, right, bottom]
  local w = mon.width / mon.scale
  local h = mon.height / mon.scale
  local tw = math.floor((w - (r[1] or 0) - (r[3] or 0) - 2 * gaps_out - (n - 1) * gaps_in) / n)
  local th = math.floor(h - (r[2] or 0) - (r[4] or 0) - 2 * gaps_out)

  for _, win in ipairs(wins) do
    hl.dispatch(hl.dsp.focus({ window = "address:" .. win.address }))
    hl.dispatch(hl.dsp.window.resize({ exact = true, x = tw, y = th }))
  end
end

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
hl.bind(mod .. " + F", focus_toggle)
-- Fullscreen
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.fullscreen(1))
-- Equalize all tiled windows on the focused monitor to the same size
hl.bind(mod .. " + equal", equalize)
-- Toggle floating
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))

-- Special workspace (scratchpad / magic)
hl.bind(mod .. " + minus", hl.dsp.workspace.toggle_special("magic"))
hl.bind(
  mod .. " + SHIFT + minus",
  hl.dsp.window.move({ workspace = "special:magic" })
)

-- Minimize stash (special:MinimizedApps)
-- SUPER+M peeks/hides the stash; SUPER+SHIFT+M minimizes the focused window;
-- SUPER+SHIFT+return restores the focused stashed window to the workspace you
-- came from ("previous" = last-active normal workspace before the toggle).
hl.bind(mod .. " + M", hl.dsp.workspace.toggle_special("MinimizedApps"))
hl.bind(
  mod .. " + SHIFT + M",
  hl.dsp.window.move({ workspace = "special:MinimizedApps" })
)
hl.bind(
  mod .. " + SHIFT + return",
  hl.dsp.window.move({ workspace = "previous" })
)

-- Reload + cycle wallpaper
hl.bind(
  mod .. " + SHIFT + R",
  hl.dsp.exec_cmd(
    "hyprctl reload && pkill phonto; phonto --rand & notify-send 'hyprland reloaded 👍'"
  )
)

-- Refresh noctalia after loading a new version (scoped — no session restart)
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd("reload-noctalia"))

-- Workspace navigation (ctrl due to keyd remappings)
hl.bind(ctrl .. " + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(ctrl .. " + right", hl.dsp.focus({ workspace = "e+1" }))

-- Focus + move windows with hjkl
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(directions) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
  -- swap (not move): exchanges window positions without re-inserting into the
  -- dwindle tree, so neighbours keep their sizes instead of resizing.
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = dir }))
end

-- Switch workspaces / move windows 1–9
for i = 1, 9 do
  hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Audio
hl.bind(
  "XF86AudioRaiseVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true }
)

hl.bind(
  "XF86AudioLowerVolume",
  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true }
)
hl.bind(
  "XF86AudioPlay",
  hl.dsp.exec_cmd("playerctl play-pause"),
  { locked = true }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(
  "XF86AudioPrev",
  hl.dsp.exec_cmd("playerctl previous"),
  { locked = true }
)

-- Hyprsunset: temperature + gamma (repeating on hold)
hl.bind(
  mod .. " + XF86MonBrightnessDown",
  hl.dsp.exec_cmd("hyprctl hyprsunset temperature -250"),
  { repeating = true }
)
hl.bind(
  mod .. " + XF86MonBrightnessUp",
  hl.dsp.exec_cmd("hyprctl hyprsunset temperature +250"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86MonBrightnessDown",
  hl.dsp.exec_cmd("hyprctl hyprsunset gamma -10"),
  { repeating = true, locked = true }
)
hl.bind(
  "XF86MonBrightnessUp",
  hl.dsp.exec_cmd("hyprctl hyprsunset gamma +10"),
  { repeating = true, locked = true }
)

-- Drag / resize with mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---- RESIZE SUBMAP ----
hl.bind(mod .. " + R", hl.dsp.submap("resize"))
-- NOTE: no "reset" 2nd arg — that stamps every bind to auto-exit the submap
-- after one fire (KeybindManager: setSubmap(submap.reset) post-dispatch).
-- Omitting it keeps the submap sticky so h/j/k/l repeat until escape/return.
hl.define_submap("resize", function()
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
