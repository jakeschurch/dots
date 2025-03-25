{
  inputs,
  ...
}:
[
  inputs.nixGL.overlay
  inputs.tfenv.overlays.default
]
++ inputs.nixpkgs.lib.singleton (
  _: prev: {
    lib =
      prev.lib
      // (import ./lib {
        inherit inputs;
        inherit (prev) pkgs;
      });

    terragrunt = prev.terragrunt.overrideAttrs (_: {
      version = "0.69.1";
    });

    inherit (inputs) lexical-lsp;
    inherit (inputs.nixpkgs) narHash;

    unstable = (import inputs.unstable { inherit (prev) system; }) // {
      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    };
  }
)
