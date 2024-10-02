{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      unstable.terragrunt
    ];

    shellAliases = {
      tg = "terragrunt --terragrunt-source $(git rev-parse --show-toplevel) --terragrunt-forward-tf-stdout";
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
