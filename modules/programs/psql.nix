{pkgs, ...}: let
  psql = pkgs.stdenv.mkDerivation {
    name = "psql";
    src = pkgs.postgresql;

    buildInputs = with pkgs; [
      pkg-config
      openssl
      readline
    ];
    installPhase = ''
      mkdir -p $out/bin
      cp ${pkgs.postgresql}/bin/psql $out/bin
    '';
  };
in {
  home.packages = [
    psql
  ];
}
