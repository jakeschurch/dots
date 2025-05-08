{
  stdenv,
  pkgs,
  ...
}:
with pkgs;
let
  psql = stdenv.mkDerivation {
    name = "psql";
    src = postgresql;

    buildInputs = [
      pkg-config
      openssl
      readline
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${postgresql}/bin/psql $out/bin
    '';
  };
in
{
  home.packages = [
    psql
  ];
}
