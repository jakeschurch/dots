{ pkgs, lib, ... }:
{
  home = {
    packages = with pkgs; [
      unstable.terragrunt
    ];

    shellAliases = {
      tg_pretty_print = "sed -f ~/Projects/work/infrastructure/.github/workflows/auxiliary/terraform_pretty_patterns.sed";
      tg =
        let
          args = lib.strings.concatStringsSep " " [
            "--experiment cli-redesign"
            "--tf-forward-stdout"
            "--use-partial-parse-config-cache"
            "--backend-require-bootstrap"
            "--source-map \"git::git@github.com:fieldguide/infrastructure.git=$(git rev-parse --show-toplevel)\""
          ];
        in
        "terragrunt run ${args}";

      tgr = "tg --all";
      tg_plan = "tg plan";
      tg_refresh = "tgr refresh";
      tg_init = "tgr init";
      tg_apply = "tgr apply";
      tg_import = "tg import";
      tg_state = "tg state";
    };
  };
}
