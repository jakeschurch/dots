{
  lib,
  config,
  pkgs,
  ...
}: {
  home = {
    stateVersion = "23.11";

    activation = {
      darwinFileLimits =
        lib.mkIf
        (pkgs.system == "x86_64-darwin" || pkgs.system == "aarch64-darwin")
        (lib.hm.dag.entryAfter ["writeBoundary"] ''
          #launchctl limit maxfiles 5000000 5000000
          #ulimit -n 10240
        '');

      aliasApplications =
        lib.mkIf
        (pkgs.system == "x86_64-darwin" || pkgs.system == "aarch64-darwin")
        (lib.hm.dag.entryAfter ["writeBoundary"] ''
          app_folder=$(echo ~/Applications);
          for app in $(find "$genProfilePath/home-path/Applications" -type l); do
            $DRY_RUN_CMD rm -f $app_folder/$(basename $app)
            $DRY_RUN_CMD /usr/bin/osascript -e "tell app \"Finder\"" -e "make new alias file at POSIX file \"$app_folder\" to POSIX file \"$app\"" -e "set name of result to \"$(basename $app)\"" -e "end tell"
          done
        '');
    };

    packages = with pkgs; [noto-fonts-emoji jetbrains-mono];
  };

  programs.home-manager.enable = true;

  imports = [./modules];

  xdg = {
    # Let Home Manager install and manage itself.
    enable = true;
    dataHome = "${config.home.homeDirectory}/.local/share";
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
  };

  manual.manpages.enable = true;

  nix = {
    settings = {
      auto-optimise-store = true;
      allowed-users = ["*"];
      trusted-users = ["root" "@wheel" "jake" "jakeschurch"];
      builders = "@/etc/nix/machines";
      extra-experimental-features = "nix-command flakes";
      fallback = true;

      cores = 0;
      max-jobs = "auto";
      sandbox = lib.hasInfix "darwin" pkgs.system;

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

      warn-dirty = false;
    };

    extraOptions = ''
      accept-flake-config = true
      min-free = ${toString (100 * 1024 * 1024)}
      max-free = ${toString (1024 * 1024 * 1024)}

      builders-use-substitutes = true

      # diff-hook = /etc/nix/my-diff-hook
      run-diff-hook = false
      post-build-hook = /etc/nix/upload-to-cache.sh

      http-connections = 0
      keep-failed = false
      keep-going = false
      keep-outputs = true
      keep-derivations = false

      require-sigs = false

      ${lib.optionalString (pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-linux") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      ''}
    '';
  };
}
