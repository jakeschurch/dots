{
  pkgs,
  lib,
  ...
}:
lib.mkIf pkgs.stdenv.isDarwin {
  home.packages = with pkgs; [
    nodejs_22
    pnpm
    hasura-cli
    ngrok
    eksctl
  ];
}
