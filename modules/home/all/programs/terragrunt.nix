{
  pkgs,
  lib,
  ...
}:
{
  home = {
    packages = with pkgs; [
      terragrunt
    ];

    shellAliases = {
      tg =
        let
          args = lib.strings.concatStringsSep " " [
            "--download-dir $(git rev-parse --show-toplevel)/.terragrunt-cache"
            "--dependency-fetch-output-from-state"
            "--provider-cache"
            "--provider-cache-dir $(git rev-parse --show-toplevel)/.provider-cache"
            "--tf-forward-stdout"
            "--use-partial-parse-config-cache"
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
