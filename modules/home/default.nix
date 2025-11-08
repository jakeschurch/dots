{
  flake,
  ...
}:
let
  inherit (flake) inputs;
in
{
  imports = [
    ./all
    inputs.nix-colors.homeManagerModules.default
  ];

  programs.bottom.enable = true;
  programs.home-manager.enable = true;

  home.username = flake.config.me.username;
}
