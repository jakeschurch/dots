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
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.rust
            pkgs.wayland
            pkgs.libxkbcommon
            pkgs.vulkan-loader
            pkgs.vulkan-tools
            pkgs.nvidia_x11 # Nvidia proprietary driver
          ];

          shellHook = ''
            # Make Wayland backend work
            export WINIT_UNIX_BACKEND=wayland

            # Make wgpu find Vulkan and Nvidia GPU
            export WGPU_BACKEND=vulkan
            export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.nvidia_x11}/lib
            export VK_ICD_FILENAMES=/run/opengl-driver/etc/vulkan/icd.d/nvidia_icd.json
            export VK_LAYER_PATH=/run/opengl-driver/etc/vulkan/explicit_layer.d

            # Optional: show debug info
            echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
            echo "VK_ICD_FILENAMES=$VK_ICD_FILENAMES"
          '';
        };
      }
    );
}
