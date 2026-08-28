{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;

  # Same derivations used for both the compositor's plugin list AND the .so paths
  # exported below, so the loaded binaries always match the running Hyprland ABI.
  hyprbars = inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars;
  dynamic-cursors = inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    plugins = [
      hyprbars
      dynamic-cursors
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk # file picker, misc
    ];
  };

  environment = {
    systemPackages = with pkgs; [
      hyprsunset

      (pkgs.writeScriptBin "ocr-shot" (builtins.readFile ./ocr-shot.sh))

      # Refresh noctalia-shell after a rebuild WITHOUT restarting the Wayland
      # session. A new noctalia store path changes QS_CONFIG_PATH, which moves
      # quickshell's IPC socket — so the running instance must be replaced. Only
      # the shell process is touched; the compositor/session is left alone.
      #
      # NOTE: do NOT use `pkill -x quickshell` here — the Nix wrapper's comm is
      # ".quickshell-wrapped", so an exact-name match never fires and the old
      # instance survives (a stale store path leaves the launcher IPC dead while
      # a duplicate stacks on top). Kill by the real PIDs that `noctalia-shell
      # list` reports; that works regardless of store path.
      (pkgs.writeShellScriptBin "reload-noctalia" ''
        pids() {
          noctalia-shell list 2>/dev/null \
            | ${pkgs.gawk}/bin/awk '/Process ID:/ { print $NF }'
        }
        for pid in $(pids); do kill "$pid" 2>/dev/null || true; done
        # wait for the IPC socket to drain so the relaunch isn't seen as a dup
        for _ in $(seq 1 20); do
          [ -z "$(pids)" ] && break
          sleep 0.1
        done
        ${pkgs.uwsm}/bin/uwsm app -- noctalia-shell
        ${pkgs.libnotify}/bin/notify-send 'noctalia reloaded 👍'
      '')

      (pkgs.writeShellScriptBin "smart-kill" ''
        class=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r ".class")
        if [ "$class" = "Steam" ] || [ "$class" = "Bitwarden" ]; then
          ${pkgs.xdotool}/bin/xdotool getactivewindow windowunmap
        else
          ${pkgs.hyprland}/bin/hyprctl dispatch killactive ""
        fi
      '')

      (pkgs.writeShellScriptBin "claude-workspaces" ''
        FOUNDRYBOX="$HOME/Projects/foundrybox"
        VMETAL="$HOME/Projects/homelab/vmetal"
        DOTS="$HOME/.dots"

        uwsm app -- ${pkgs.wezterm}/bin/wezterm start --cwd "$FOUNDRYBOX" -- claude --dangerously-skip-permissions /remote-control &

        for i in $(seq 1 30); do
          WINDOW_ID=$(${pkgs.wezterm}/bin/wezterm cli list --format json 2>/dev/null | ${pkgs.jq}/bin/jq -r 'map(.window_id) | max // empty')
          [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ] && break
          sleep 0.5
        done

        [ -z "$WINDOW_ID" ] && exit 1

        ${pkgs.wezterm}/bin/wezterm cli spawn --window-id "$WINDOW_ID" --cwd "$VMETAL" -- claude --dangerously-skip-permissions /remote-control
        ${pkgs.wezterm}/bin/wezterm cli spawn --window-id "$WINDOW_ID" --cwd "$DOTS" -- claude --dangerously-skip-permissions /remote-control
      '')

      (pkgs.writeShellScriptBin "claude-box" ''
        # New tmux session (random name) running claude /remote-control in $PWD.
        session="claude-$RANDOM"
        ${pkgs.tmux}/bin/tmux new-session -d -s "$session" -c "$PWD" \
          'claude --dangerously-skip-permissions /remote-control'
        echo "started $session"
        # attach when run from a terminal; stay detached otherwise
        [ -t 1 ] && exec ${pkgs.tmux}/bin/tmux attach -t "$session"
      '')

      (tesseract5.override {
        enableLanguages = [
          "eng"
          "osd"
        ];
      })
      slurp
      grim
      xdotool

      hyprshot
      hyprpicker
      cliphist
      wl-clip-persist
      nautilus
      tuigreet
      inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default
      inputs.phonto.packages.${pkgs.system}.default
      inputs.noctalia.packages.${pkgs.system}.default
      wl-clipboard-rs
      libnotify
    ];

    etc."greetd/environments".text = ''
      hyprland
      fish
      zsh
      bash
    '';

    variables = {
      NIXOS_OZONE_WL = "1";
      # Plugin .so paths for hyprland.lua to hl.plugin.load() at config parse.
      # A raw lua config replaces the generated hyprland.conf where programs.
      # hyprland.plugins would inject its load lines, so nothing loads the plugins
      # unless the lua does it. Passing the paths through the environment keeps the
      # store paths out of the lua file while guaranteeing an ABI match (same
      # derivations as programs.hyprland.plugins above).
      HYPR_PLUGIN_HYPRBARS = "${hyprbars}/lib/libhyprbars.so";
      HYPR_PLUGIN_DYNAMIC_CURSORS = "${dynamic-cursors}/lib/libhypr-dynamic-cursors.so";
      # phonto (wallpaper) uses GStreamer but ships as raw ELF without GST_PLUGIN_PATH
      # decodebin3 lives in gst-plugins-base/lib/gstreamer-1.0/libgstplayback.so
      GST_PLUGIN_PATH = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (
        with pkgs.gst_all_1;
        [
          gstreamer
          gst-plugins-base
          gst-plugins-good
          gst-plugins-bad
          gst-libav
        ]
      );
    };
  };
}
