{
  pkgs,
  inputs,
  self,
  ...
}:
with inputs; {
  nix = {
    settings = {
      trusted-users = ["root" "@wheel" "jake" "jakeschurch"];

      allowed-users = ["*"];
      builders = "@/etc/nix/machines";
      experimental-features = ["nix-command flakes pipe-operators"];
      fallback = true;

      cores = 0;
      max-jobs = "auto";
      sandbox = pkgs.stdenv.isDarwin;

      trusted-substituters = [
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
        "s3://nix-cache?trusted=1"
        "s3://nix-cache?profile=default&scheme=https&endpoint=s3.jakeschurch.com&trusted=1"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      extra-trusted-public-keys = [
        "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
        "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
        "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
        "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
        "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
        "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
        "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
        "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
      ];

      # always-allow-substitutes = true;
      extra-trusted-substituters = ["https://cache.flakehub.com"];

      warn-dirty = false;
    };

    optimise.automatic = true;

    nixPath = let path = toString ./.; in ["repl=${path}/repl.nix" "nixpkgs=${nixpkgs}"];

    registry = {
      self.flake = self;
      nixpkgs.flake = nixpkgs;
      nixpkgs.to = {
        type = "path";
        inherit (pkgs) path narHash;
      };
    };

    extraOptions = ''
      accept-flake-config = true
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      builders-use-substitutes = true
      extra-nix-path = nixpkgs=flake:nixpkgs

      # diff-hook = /etc/nix/my-diff-hook
      run-diff-hook = false
      # post-build-hook = /etc/nix/upload-to-cache.sh

      http-connections = 0
      keep-failed = false
      keep-going = false
      keep-outputs = true
      keep-derivations = false

      require-sigs = false

      ${pkgs.lib.optionalString (pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-linux") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      ''}
    '';
  };
}
