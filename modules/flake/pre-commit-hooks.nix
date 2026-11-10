{
  perSystem = _: {
    pre-commit = {
      settings.hooks = {
        check-merge-conflicts.enable = true;
        check-shebang-scripts-are-executable.enable = true;
        check-symlinks.enable = true;
        deadnix.enable = true;
        detect-private-keys.enable = true;
        end-of-file-fixer.enable = true;
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
