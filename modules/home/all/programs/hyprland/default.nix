{ flake, config, osConfig, lib, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [ ./tablet.nix ];

  config = lib.mkIf osConfig.profiles.desktop.enable {
    # Lua config (Hyprland 0.55+) — takes precedence over any generated hyprland.conf
    xdg.configFile."hypr/hyprland.lua".source =
      "${inputs.self}/configurations/nixos/apollo/hyprland.lua";

    # phonto wallpaper config — --rand picks randomly from search_paths
    xdg.configFile."phonto/config.toml".text = ''
      [[search_paths]]
      path = "${config.home.homeDirectory}/.dots/wallpapers"
      depth = 1
    '';

    # Kill animated wallpaper + shell when gaming (frees ~900MiB VRAM), restore on exit
    xdg.configFile."gamemode.ini".text = ''
      [custom]
      start=pkill -x phonto; pkill -x quickshell
      end=uwsm app -- phonto --rand; uwsm app -- noctalia-shell
    '';
  };
}
