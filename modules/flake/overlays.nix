{ inputs, ... }:
{
  perSystem =
    {
      system,
      ...
    }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;

        config = {
          allowUnfree = true;
          cudaSupport = false;
          allowBroken = true;

          allowUnfreePredicate = pkg: builtins.elem (inputs.nixpkgs.lib.getName pkg) [ "terraform-1.9.6" ];

          permittedInsecurePackages = [ "electron-19.1.9" ];
        };

        overlays = [
          (_final: prev: {
            lib =
              prev.lib
              // (import ../../lib {
                inherit inputs;
                pkgs = prev;
              });

            inherit (inputs) lexical-lsp;
            inherit (inputs.nixpkgs) narHash;

            nodejs = prev.pkgs.nodejs_22;
            nodejs_20 = prev.pkgs.nodejs_22;

            VimPlugins.blink-pairs = inputs.blink-pairs;

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

            mcp-hub = inputs.mcp-hub.packages.${prev.system}.default;

            neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
          })
        ]
        ++ [
          inputs.tfenv.overlays.default
        ];
      };
    };
}
