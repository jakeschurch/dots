{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = with pkgs; [
    nodejs_20
    hasura-cli
    ngrok
    eksctl
  ];
}
