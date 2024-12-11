let
  flake = builtins.getFlake (toString ./.);
  nixpkgs = import <nixpkgs> {};
in
  {inherit flake;}
  // flake
  // builtins
  // nixpkgs.pkgs
  // nixpkgs.lib
  // flake.darwinConfigurations
