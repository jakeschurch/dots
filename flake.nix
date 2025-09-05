{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-nightly-overlay.inputs.nixpkgs.follows = "nixpkgs";

    tfenv.url = "github:cjlarose/tfenv-nix";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    blink-pairs.url = "github:saghen/blink.pairs";
    blink-pairs.inputs.nixpkgs.follows = "nixpkgs";

    nixGL = {
      url = "github:guibou/nixGL";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko/latest";
      flake = true;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lexical-lsp.url = "github:lexical-lsp/lexical";
    lexical-lsp.inputs.nixpkgs.follows = "nixpkgs";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    git-hooks-nix.url = "github:cachix/git-hooks.nix";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixd.url = "github:nix-community/nixd";
    nixd.inputs.nixpkgs.follows = "nixpkgs";

    mcp-hub.url = "github:ravitemer/mcp-hub";
    mcp-hub.inputs.nixpkgs.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";

    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland"; # Prevents version mismatch.
    };

    hy3 = {
      url = "github:outfoxxed/hy3";
      # or github:outfoxxed/hy3 to follow the development branch.
      # (you may encounter issues if you dont do the same for hyprland)
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland"; # to make sure that the plugin is built for the correct version of hyprland
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.nixos-unified.lib.mkFlake {
      inherit inputs;
      root = ./.;
    };

  nixConfig = {
    download-attempts = 3;
    http-connections = 0;

    builders = [ ];

    experimental-features = [
      "nix-command"
      "flakes"
      "auto-allocate-uids"
    ];

    allowed-impure-host-deps = [
      "/usr/bin/ditto" # for darwin builds
      "/bin/sh"
      "/usr/lib/libSystem.B.dylib"
      "/usr/lib/system/libunc.dylib"
      "/dev/zero"
      "/dev/random"
      "/dev/urandom"
    ];
  };
}
