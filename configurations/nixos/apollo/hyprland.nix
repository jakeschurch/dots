{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake) inputs;
in
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;

    plugins = with inputs.hyprland-plugins.packages.${pkgs.system}; [
      # hyprbars
      # inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
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
      (pkgs.writeShellScriptBin "reload-noctalia" ''
        ${pkgs.procps}/bin/pkill -x quickshell
        # wait for the IPC socket to drain so the relaunch isn't seen as a dup
        for _ in $(seq 1 20); do
          ${pkgs.procps}/bin/pgrep -x quickshell >/dev/null || break
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

      (pkgs.writeShellScriptBin "hypr-focus-toggle" ''
        HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
        JQ="${pkgs.jq}/bin/jq"

        ACTIVE=$($HYPRCTL activewindow -j)
        ACTIVE_ADDR=$(echo "$ACTIVE" | $JQ -r '.address')
        ACTIVE_WS=$(echo "$ACTIVE" | $JQ -r '.workspace.id')

        # Per-workspace stash: special:focusstash-N isolates stashes per workspace
        # Hyprland 0.55+ IPC uses Lua dispatch: hyprctl dispatch '<lua expr>'
        # Old hyprlang syntax (e.g. "movetoworkspace 1,address:0x...") fails with Lua parser
        STASH_WS="focusstash-$ACTIVE_WS"
        STASH_FILE="/tmp/hypr-focus-stash-$ACTIVE_WS"

        if [ -f "$STASH_FILE" ]; then
          # Exit focus mode: restore all windows stashed from this workspace
          while true; do
            STASH_WIN=$($HYPRCTL clients -j | $JQ -r --arg s "special:$STASH_WS" \
              '[.[] | select(.workspace.name == $s)] | first | .address // empty')
            [ -z "$STASH_WIN" ] && break
            $HYPRCTL dispatch "hl.dsp.window.move({workspace = $ACTIVE_WS, window = 'address:$STASH_WIN'})"
          done
          rm -f "$STASH_FILE"
        else
          # Enter focus mode: stash all other windows in active workspace
          touch "$STASH_FILE"
          OTHERS=$($HYPRCTL clients -j | $JQ -r --arg ws "$ACTIVE_WS" --arg addr "$ACTIVE_ADDR" \
            '[.[] | select(.workspace.id == ($ws | tonumber) and .address != $addr and .mapped == true)] | .[].address')
          for ADDR in $OTHERS; do
            $HYPRCTL dispatch "hl.dsp.window.move({workspace = 'special:$STASH_WS', window = 'address:$ADDR'})"
          done
          # Re-focus kept window: stash opens the special workspace, shifting focus there.
          # Without this, the stashed window follows workspace switches.
          $HYPRCTL dispatch "hl.dsp.focus({window = 'address:$ACTIVE_ADDR'})"
        fi
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
