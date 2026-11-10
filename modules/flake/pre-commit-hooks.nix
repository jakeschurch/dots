{
  perSystem =
    { config, pkgs, ... }:
    {
      # `nix develop` (re)installs .git/hooks/pre-commit from the config below;
      # rerun it after changing hooks or the installed hook stays stale.
      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;
      };

      pre-commit = {
        settings.hooks = {
          check-merge-conflicts.enable = true;
          check-shebang-scripts-are-executable.enable = true;
          check-symlinks.enable = true;
          deadnix.enable = true;
          detect-private-keys.enable = true;
          end-of-file-fixer.enable = true;
          gitleaks.enable = true;
          nixfmt.enable = true;
          pretty-format-json = {
            enable = true;
            # Claude Code rewrites this file in its own key order on /config.
            excludes = [ "modules/home/all/services/claude/settings\\.json" ];
          };
          pre-commit-hook-ensure-sops.enable = true;
          shellcheck.enable = true;
          sort-simple-yaml.enable = true;
          statix.enable = true;
          treefmt.enable = true;
        };
      };
    };
}
