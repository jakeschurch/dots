{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  home.packages = with pkgs; [
    inputs.wl-starfield.packages.${pkgs.system}.default
    hyprsunset
  ];
}
