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
      hyprbars
      inputs.hypr-dynamic-cursors.packages.${pkgs.system}.hypr-dynamic-cursors
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

      (pkgs.writeShellScriptBin "smart-kill" ''
        class=$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r ".class")
        if [ "$class" = "Steam" ] || [ "$class" = "Bitwarden" ]; then
          ${pkgs.xdotool}/bin/xdotool getactivewindow windowunmap
        else
          ${pkgs.hyprland}/bin/hyprctl dispatch killactive ""
        fi
      '')

      (pkgs.writeShellScriptBin "hypr-focus-toggle" ''
        HYPRCTL="${pkgs.hyprland}/bin/hyprctl"
        JQ="${pkgs.jq}/bin/jq"
        STASH_FILE="/tmp/hypr-focus-stash"

        ACTIVE=$($HYPRCTL activewindow -j)
        ACTIVE_ADDR=$(echo "$ACTIVE" | $JQ -r '.address')
        ACTIVE_WS=$(echo "$ACTIVE" | $JQ -r '.workspace.id')
        ACTIVE_WS_NAME=$(echo "$ACTIVE" | $JQ -r '.workspace.name')

        if [ "$ACTIVE_WS_NAME" = "special:focusstash" ]; then
          # Exit focus mode: move active window back, then restore stashed windows
          PREV_WS=$(cat "$STASH_FILE" 2>/dev/null | $JQ -r '.workspace')
          $HYPRCTL dispatch movetoworkspace "$PREV_WS,address:$ACTIVE_ADDR"
          # Move all remaining stash windows back
          while true; do
            STASH_WIN=$($HYPRCTL clients -j | $JQ -r '[.[] | select(.workspace.name == "special:focusstash")] | first | .address // empty')
            [ -z "$STASH_WIN" ] && break
            $HYPRCTL dispatch movetoworkspacesilent "$PREV_WS,address:$STASH_WIN"
          done
          rm -f "$STASH_FILE"
        else
          # Enter focus mode: stash all other windows in active workspace
          echo "{\"workspace\": $ACTIVE_WS}" > "$STASH_FILE"
          OTHERS=$($HYPRCTL clients -j | $JQ -r --arg ws "$ACTIVE_WS" --arg addr "$ACTIVE_ADDR" \
            '[.[] | select(.workspace.id == ($ws | tonumber) and .address != $addr and .mapped == true)] | .[].address')
          for ADDR in $OTHERS; do
            # Use movetospecialworkspace to avoid Lua colon-parsing bug with "special:name" syntax
            $HYPRCTL dispatch movetospecialworkspace "focusstash,address:$ADDR"
          done
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
