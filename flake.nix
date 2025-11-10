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
    walker.url = "github:abenz1267/walker";

    wl-starfield.url = "github:jakeschurch/wl-starfield/bugfix/limit-fps-render";

    hyprland = {
      url = "github:hyprwm/Hyprland?ref=v0.52.0";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins?ref=v0.52.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprland.follows = "hyprland";
    };

    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    rose-pine-hyprcursor = {
      url = "github:ndom91/rose-pine-hyprcursor";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hyprlang.follows = "hyprland/hyprlang";
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
    download-buffer-size = 904857600; # 900 MiB

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
