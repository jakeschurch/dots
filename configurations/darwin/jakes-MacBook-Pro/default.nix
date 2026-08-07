{
  lib,
  flake,
  pkgs,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.darwinModules.default
  ];

  system.primaryUser = "jake";
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  # GUI machine: home modules gated on this get their desktop apps (Slack, Bitwarden GUI).
  profiles.desktop.enable = true;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  environment.systemPackages = with pkgs; [
    awscli2
    nodejs_22
    pnpm
    hasura-cli
    ngrok
    eksctl
  ];
}
