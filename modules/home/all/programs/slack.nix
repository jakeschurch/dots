{ pkgs, osConfig, lib, ... }:
{
  home.packages = lib.optionals osConfig.profiles.desktop.enable (with pkgs; [ slack ]);
}
