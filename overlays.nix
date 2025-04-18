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

    inherit (inputs) lexical-lsp;
    inherit (inputs.nixpkgs) narHash;

    prev.VimPlugins.blink-pairs = inputs.blink-pairs;

    mcp-hub = inputs.mcp-hub.packages.${prev.pkgs.system}.default;

    unstable = (import inputs.unstable { inherit (prev) system; }) // {

      VimPlugins.blink-pairs = inputs.blink-pairs;

      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    };
  }
)
