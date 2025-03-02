{
  pkgs,
  inputs,
  system,
  ...
}:
let
  ccachedPkgs = [
    # "neovim-nightly"
  ];

  ccacheStdenvPkgs =
    self: super:
    pkgs.lib.genAttrs ccachedPkgs (
      pn: super.${pn}.override { stdenv = builtins.trace "with ccache: ${pn}" self.ccacheStdenv; }
    );

  ccacheOverlay = _self: super: {
    ccacheWrapper = super.ccacheWrapper.override {
      extraConfig = ''
        export CCACHE_COMPRESS=1
        export CCACHE_DIR="/nix/var/cache/ccache"
        export CCACHE_UMASK=007
        if [ ! -d "$CCACHE_DIR" ]; then
          echo "====="
          echo "Directory '$CCACHE_DIR' does not exist"
          echo "Please create it with:"
          echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
          echo "  sudo chown root:nixbld '$CCACHE_DIR'"
          echo "====="
          exit 1
        fi
        if [ ! -w "$CCACHE_DIR" ]; then
          echo "====="
          echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
          echo "Please verify its access permissions"
          echo "====="
          exit 1
        fi
      '';
    };
  };
in
[
  ccacheOverlay
  ccacheStdenvPkgs
  (_: prev: {
    lib =
      prev.lib
      // import ./lib {
        inherit inputs;
        inherit (prev) pkgs;
      };

    neovim-nightly = inputs.neovim-nightly-overlay.packages.${prev.system}.default;
    unstable = import inputs.unstable { inherit (prev) system; };
  })

  inputs.nixGL.overlay
  inputs.tfenv.overlays.default
]
