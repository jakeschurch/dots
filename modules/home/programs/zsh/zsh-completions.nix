{
  pkgs,
  lib,
  packages,
  ...
}:
let
  inherit (pkgs) stdenv;

  mkZshCompletion =
    package:
    stdenv.mkDerivation rec {
      name = package.pname;
      pname = "${package.pname}-zsh-completions";
      inherit (package) version;

      nativeBuildInputs = [ package ];
      src = package;

      buildPhase = ''
        mkdir -p $out
        ${package}/bin/${package.pname} completion zsh > $out/_${pname}
      '';

      patchPhase = false;

      meta = with lib; {
        description = pname;
        platforms = platforms.all;
      };
    };
in
map mkZshCompletion packages
