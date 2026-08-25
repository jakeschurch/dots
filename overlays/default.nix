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

  nur = import inputs.nur {
    nurpkgs = super;
    pkgs = super;
  };

  # tmux 3.7's configure aborts on darwin unless jemalloc is explicitly enabled
  # or disabled (macOS calloc(3) does not always zero allocations). nixpkgs
  # passes neither, so the darwin build fails; enable it with the dependency.
  tmux =
    if super.stdenv.hostPlatform.isDarwin then
      super.tmux.overrideAttrs (old: {
        buildInputs = (old.buildInputs or [ ]) ++ [ super.jemalloc ];
        configureFlags = (old.configureFlags or [ ]) ++ [ "--enable-jemalloc" ];
      })
    else
      super.tmux;

  # Pin claude-code ahead of nixpkgs. Version and checksums live in
  # claude-code.json; refresh them with `bin/update-claude-code` (stable channel
  # by default, `bin/update-claude-code latest` or an explicit version too).
  claude-code = super.claude-code.overrideAttrs (
    _old:
    let
      pin = builtins.fromJSON (builtins.readFile ./claude-code.json);
      inherit (pin) version;
      platformKey = "${super.stdenv.hostPlatform.node.platform}-${super.stdenv.hostPlatform.node.arch}";
      inherit (pin) checksums;
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
