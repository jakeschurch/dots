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

  ast-grep = inputs.nixpkgs-stable.legacyPackages.${super.system}.ast-grep;

  expert = inputs.expert.packages.${super.system}.default;
  mcp-hub = inputs.mcp-hub.packages.${super.system}.default;
  neovim-nightly =
    inputs.neovim-nightly-overlay.packages.${super.system}.default.overrideAttrs
      (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/applications
          touch $out/share/applications/nvim.desktop
        '';
      });
  bun2nix = inputs.bun2nix.packages.${super.system}.default;

  # llama.cpp with CUDA support (NVIDIA only)
  llama-cpp-cuda = super.llama-cpp.override {
    cudaSupport = true;
    openclSupport = false;
  };

  nur = import inputs.nur {
    nurpkgs = super;
    pkgs = super;
  };

  # Pin claude-code ahead of nixpkgs (2.1.161 as of 2026-06-10).
  # Checksums from https://downloads.claude.ai/claude-code-releases/<version>/manifest.json
  claude-code = super.claude-code.overrideAttrs (
    old:
    let
      version = "2.1.170";
      platformKey = "${super.stdenv.hostPlatform.node.platform}-${super.stdenv.hostPlatform.node.arch}";
      checksums = {
        linux-x64 = "849e007277a0442ab27570d3e3d6d43787507946590e8dd1947e5a39b7081f9e";
        linux-arm64 = "1bb9d032440a75532f7dd4cafbc687f220aaf16c63eba17e192dfbec2f04bd25";
        darwin-arm64 = "e903646d8b7a31882a80ecd27569a27d8ac57b3708745f349709632c84117fdf";
        darwin-x64 = "914f23a70bbed5d9ae567e3e04b86206ed9971b371bc9baca3f79c8885bfddb4";
      };
    in
    {
      inherit version;
      src = super.fetchurl {
        url = "https://downloads.claude.ai/claude-code-releases/${version}/${platformKey}/claude";
        sha256 = checksums.${platformKey};
      };
    }
  );
}
// packageOverlays
