{
  inputs,
  system,
  ...
}:
[
  # ccacheOverlay
  # ccacheStdenvPkgs
  (_final: prev: {
    lib =
      prev.lib
      // (import ./lib {
        inherit inputs;
        inherit (prev) pkgs;
      });

    unstable = (import inputs.unstable { inherit (prev) system; }) // {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    };
  })

  inputs.nixGL.overlay
  inputs.tfenv.overlays.default
]
