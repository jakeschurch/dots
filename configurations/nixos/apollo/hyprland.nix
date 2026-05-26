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
        ]
      );
    };
  };
}
