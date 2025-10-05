{
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs config;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
  ];

  me = {
    username = "jake";
    fullname = "Jake Schurch";
    email = "jakeschurch@gmail.com";
  };

  home.packages = with pkgs; [
    inputs.wl-starfield.packages.${pkgs.system}.default
    hyprsunset
  ];

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}
