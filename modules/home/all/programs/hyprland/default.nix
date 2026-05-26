{ flake, config, ... }:
let
  inherit (flake) inputs;
in
{
  imports = [
    ./tablet.nix
  ];

  # Lua config (Hyprland 0.55+) — takes precedence over any generated hyprland.conf
  xdg.configFile."hypr/hyprland.lua".source =
    "${inputs.self}/configurations/nixos/apollo/hyprland.lua";

  # phonto wallpaper config — --rand picks randomly from search_paths
  xdg.configFile."phonto/config.toml".text = ''
    [[search_paths]]
    path = "${config.home.homeDirectory}/.dots/wallpapers"
    depth = 1
  '';
}
