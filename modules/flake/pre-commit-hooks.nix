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
          check-added-large-files = {
            enable = true;
            # Wallpapers top out under 1 MiB; anything bigger is a mistake.
            args = [ "--maxkb=1024" ];
          };
          check-case-conflicts.enable = true;
          check-executables-have-shebangs.enable = true;
          check-toml.enable = true;
          check-yaml.enable = true;
          convco.enable = true;
          mixed-line-endings.enable = true;
          selene.enable = true;
          trim-trailing-whitespace.enable = true;
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
          statix.enable = true;
          treefmt.enable = true;
        };
      };
    };
}
