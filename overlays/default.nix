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

  expert = inputs.expert.packages.${super.stdenv.hostPlatform.system}.default;
  mcp-hub = inputs.mcp-hub.packages.${super.stdenv.hostPlatform.system}.default;
  neovim-nightly =
    inputs.neovim-nightly-overlay.packages.${super.stdenv.hostPlatform.system}.default.overrideAttrs
      (old: {
        postInstall = (old.postInstall or "") + ''
          mkdir -p $out/share/applications
          touch $out/share/applications/nvim.desktop
        '';
      });
  bun2nix = inputs.bun2nix.packages.${super.stdenv.hostPlatform.system}.default;

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

  # mosh 1.4.0's configure probe compiles protoc output against abseil
  # 20260817, whose btree_map using-declarations fail under mosh's default C++
  # standard. Force C++20 until nixpkgs fixes it. CXXFLAGS rather than
  # NIX_CFLAGS_COMPILE: the latter also reaches C compiles, where clang rejects
  # -std=c++20 and configure's compiler check fails. C++20 also drops
  # shared_ptr::unique(), so swap in the equivalent use_count() check.
  mosh = super.mosh.overrideAttrs (old: {
    env = (old.env or { }) // {
      CXXFLAGS = "-g -O2 -std=c++20";
    };
    postPatch = (old.postPatch or "") + ''
      substituteInPlace src/terminal/terminalframebuffer.h \
        --replace-fail 'mutable_row.unique()' '(mutable_row.use_count() == 1)'
    '';
  });

  # mux::tab::adjust_{x,y}_size spin forever when a window shrinks past the
  # point where every stacked pane is already 1 cell, freezing the GUI main
  # thread (AeroSpace frame changes trigger it). Bail out when nothing can
  # shrink. Upstream: https://github.com/wezterm/wezterm/issues/7765
  wezterm = super.wezterm.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [ ./wezterm-resize-hang.patch ];
  });

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
