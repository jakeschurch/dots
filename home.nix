{
  lib,
  config,
  pkgs,
  ...
}: {
  home = {
    stateVersion = "24.05";

    activation = {
      diff = lib.hm.dag.entryAnywhere "${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath\n";
      darwinFileLimits =
        lib.mkIf
        pkgs.stdenv.isDarwin
        (lib.hm.dag.entryAfter ["writeBoundary"] ''
          #launchctl limit maxfiles 5000000 5000000
          #ulimit -n 10240
        '');

      aliasApplications = lib.mkIf pkgs.stdenv.isDarwin (lib.hm.dag.entryAfter ["writeBarrier"] ''
        new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
        rm -rf "$new_nix_apps"
        mkdir -p "$new_nix_apps"
        find -H -L "$newGenPath/home-files/Applications" -maxdepth 1 -name "*.app" -type d -print | while read -r app; do
          real_app=$(readlink -f "$app")
          app_name=$(basename "$app")
          target_app="$new_nix_apps/$app_name"
          echo "Alias '$real_app' to '$target_app'"
          ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
        done
      '');
    };
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

  home.enableNixpkgsReleaseCheck = false;
  home.packages = let
    repl_path = builtins.toString ./.;
    my-nix-repl = pkgs.writeShellScriptBin "nix-repl" ''
      if [ -f "${repl_path}/repl.nix" ]; then
        nix repl -f "${repl_path}/repl.nix" "$@"
      else
        nix repl "$@"
      fi
    '';
  in
    [
      my-nix-repl
    ]
    ++ (with pkgs; [noto-fonts-emoji jetbrains-mono]);
}
