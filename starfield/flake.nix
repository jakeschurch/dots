{
  description = "Starfield Rust devShell for NixOS Unified with Wayland + Nvidia + Vulkan";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        libPath =
          with pkgs;
          lib.makeLibraryPath [
            libGL
            libxkbcommon
            wayland
            vulkan-loader
          ];
      in
      {
        devShell =
          with pkgs;
          mkShell {
            LD_LIBRARY_PATH = libPath;
          };
      }
    );
}
