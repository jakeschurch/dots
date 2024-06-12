{pkgs, lib, ... }: lib.mkIf pkgs.stdenv.isDarwin {

  home.packages = with pkgs; [
    nodejs_18
    hasura-cli
    ngrok
    eksctl
  ];
}
