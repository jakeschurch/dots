{
  pkgs,
  lib,
  packages,
  ...
}:
let
  inherit (pkgs) stdenv;

  mkFishCompletion =
    package:
    stdenv.mkDerivation rec {
      name = package.pname;
      pname = "${package.pname}-fish-completions";
      inherit (package) version;

      nativeBuildInputs = [ package ];
      src = package;

      buildPhase = ''
        mkdir -p $out
        ${package}/bin/${package.pname} completion fish > $out/${pname}.fish
      '';

      patchPhase = false;

      meta = with lib; {
        description = pname;
        platforms = platforms.all;
      };
    };
in
map mkFishCompletion packages
