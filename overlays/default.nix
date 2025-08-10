{ flake, ... }:
let
  inherit (flake) inputs;
in
self: super:
super.lib.singleton ({
  lib =
    super.lib
    // (import ../lib {
      inherit inputs;
      pkgs = super;
    });

  inherit (inputs) lexical-lsp;
  inherit (inputs.nixpkgs) narHash;

  nodejs = super.pkgs.nodejs_22;
  nodejs_20 = super.pkgs.nodejs_22;

  VimPlugins.blink-pairs = inputs.blink-pairs;

  VimPlugins.none-ls-nvim = super.vimUtils.buildVimPlugin {
    pname = "none-ls-nvim";
    version = "git-HEAD";
    src = super.fetchFromGitHub {
      owner = "ulisses-cruz";
      repo = "none-ls.nvim";
      rev = "main"; # Or a specific commit SHA
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual
    };
  };

  mcp-hub = inputs.mcp-hub.packages.${super.system}.default;

  neovim-nightly = inputs.neovim-nightly-overlay.packages.${super.system}.default;
})
++ [
  inputs.nixGL.overlay
  inputs.tfenv.overlays.default
]
