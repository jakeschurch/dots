{
  inputs,
  ...
}:
[
  inputs.nixGL.overlay
  inputs.tfenv.overlays.default
]
++ inputs.nixpkgs.lib.singleton (
  _: prev:

  let
    unstable = import inputs.unstable { inherit (prev) system; };
  in
  {
    lib =
      prev.lib
      // (import ./lib {
        inherit inputs;
        inherit (prev) pkgs;
      });

    inherit (inputs) lexical-lsp;
    inherit (inputs.nixpkgs) narHash;

    nodejs = prev.pkgs.nodejs_22;
    nodejs_20 = prev.pkgs.nodejs_22;

    prev.VimPlugins.blink-pairs = inputs.blink-pairs;

    VimPlugins.none-ls-nvim = prev.vimUtils.buildVimPlugin {
      pname = "none-ls-nvim";
      version = "git-HEAD";
      src = prev.fetchFromGitHub {
        owner = "ulisses-cruz";
        repo = "none-ls.nvim";
        rev = "main"; # Or a specific commit SHA
        sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Replace with actual
      };
    };

    mcp-hub = inputs.mcp-hub.packages.${prev.pkgs.system}.default;

    inherit (unstable.pkgs) formats;

    unstable = unstable // {

      VimPlugins.blink-pairs = inputs.blink-pairs;

      neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    };
  }
)
