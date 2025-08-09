{
  pkgs,
  lib,
  ...
}:
let
  scripts = import ./scripts {
    inherit pkgs lib;
    inherit (pkgs.lib) mkScript;
  };

in
{
  imports = [
    scripts
  ]
  ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
}
