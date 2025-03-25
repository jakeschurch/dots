{ pkgs, ... }:
{
  nix = {
    enable = false;

    # linux-builder = {
    #   enable = pkgs.stdenv.isDarwin;
    #   ephemeral = true;
    #   maxJobs = 10;
    #   config = {
    #     virtualisation = {
    #       darwin-builder = {
    #         diskSize = 120 * 1024;
    #         memorySize = 4 * 1024;
    #       };
    #       cores = 3;
    #     };
    #   };
    # };

    settings = {
      trusted-users = [
        "root"
        "@wheel"
        "jake"
        "jakeschurch"
      ];

      allowed-users = [ "*" ];
      # builders = "@/etc/nix/machines";
      extra-experimental-features = [
        "nix-command flakes pipe-operators auto-allocate-uids ca-derivations"
      ];
      fallback = true;

      cores = 0;
      max-jobs = "auto";
      sandbox = false;

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      always-allow-substitutes = true;
      warn-dirty = false;
    };

    optimise.automatic = false;
    gc.automatic = false;

    extraOptions = ''
      accept-flake-config = true
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      builders-use-substitutes = true
      extra-nix-path = nixpkgs=flake:nixpkgs

      http-connections = 0
      require-sigs = false

      ${pkgs.lib.optionalString (pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-linux") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      ''}
    '';
  };
}
