{
  flake,
  ...
}:
let
  inherit (flake) inputs;
  inherit (inputs) self;

  packages = self + /packages;
in
self: super:
let
  # Auto-import all packages from the packages directory
  # TODO: Upstream this to nixos-unified?
  entries = builtins.readDir packages;

  # Convert directory entries to package definitions
  makePackage =
    name: type:
    let
      # Remove .nix extension for package name
      pkgName =
        if type == "regular" && builtins.match ".*\\.nix$" name != null then
          builtins.replaceStrings [ ".nix" ] [ "" ] name
        else
          name;
    in
    {
      name = pkgName;
      value = self.callPackage (packages + "/${name}") { };
    };

  # Import everything in packages directory
  packageOverlays = builtins.listToAttrs (
    builtins.attrValues (builtins.mapAttrs makePackage entries)
  );
in
{

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
}
// packageOverlays
