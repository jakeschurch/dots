{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      unstable.terragrunt
    ];

    shellAliases = {
      tg = "terragrunt --terragrunt-use-partial-parse-config-cache --terragrunt-fail-on-state-bucket-creation --terragrunt-source-map \"git::git@github.com:fieldguide/infrastructure.git=$(git rev-parse --show-toplevel)\"";
      tgr = "tg run-all";
      tg_plan = "tg plan";
      tg_refresh = "tgr refresh";
      tg_init = "tgr init";
      tg_apply = "tgr apply";
      tg_import = "tg import";
      tg_state = "tg state";
    };

    # sessionVariables = {inherit TF_PLUGIN_CACHE_DIR;};

    # activation.terragrunt-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [ ! -d ${TF_PLUGIN_CACHE_DIR} ]; then
    #     mkdir -p ${TF_PLUGIN_CACHE_DIR}
    #   fi
    # '';
  };
}
