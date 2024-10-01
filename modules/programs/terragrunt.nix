{pkgs, ...}: {
  home = {
    packages = with pkgs; [
      unstable.terragrunt
    ];

    shellAliases = {
      tg = "terragrunt --terragrunt-source $(git rev-parse --show-toplevel)";
      tgr = "terragrunt run-all --terragrunt-source $(git rev-parse --show-toplevel)";
      tg_plan = "terragrunt run-all plan --terragrunt-source $(git rev-parse --show-toplevel)";
      tg_refresh = "terragrunt run-all refresh --terragrunt-source $(git rev-parse --show-toplevel)";
      tg_init = "terragrunt run-all init --terragrunt-source $(git rev-parse --show-toplevel)";
      tg_apply = "terragrunt run-all apply --terragrunt-source $(git rev-parse --show-toplevel)";
      tg_import = "terragrunt --terragrunt-source $(git rev-parse --show-toplevel) import";
      tg_state = "terragrunt --terragrunt-source $(git rev-parse --show-toplevel) state";
    };

    # sessionVariables = {inherit TF_PLUGIN_CACHE_DIR;};

    # activation.terragrunt-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    #   if [ ! -d ${TF_PLUGIN_CACHE_DIR} ]; then
    #     mkdir -p ${TF_PLUGIN_CACHE_DIR}
    #   fi
    # '';
  };
}
