{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      terragrunt
    ];

    shellAliases = {
      tg = "terragrunt --terragrunt-forward-tf-stdout --terragrunt-use-partial-parse-config-cache --terragrunt-fail-on-state-bucket-creation --terragrunt-source-map \"git::git@github.com:fieldguide/infrastructure.git=$(git rev-parse --show-toplevel)\"";
      tgr = "tg run-all";
      tg_plan = "tg plan";
      tg_refresh = "tgr refresh";
      tg_init = "tgr init";
      tg_apply = "tgr apply";
      tg_import = "tg import";
      tg_state = "tg state";
    };
  };
}
