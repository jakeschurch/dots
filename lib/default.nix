{
  pkgs,
  ...
}:
let
  mkScript = pkgs.callPackage ./mkScript.nix { };
in
{
  inherit
    mkScript
    ;
}
