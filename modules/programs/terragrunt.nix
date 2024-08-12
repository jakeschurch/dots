{
  pkgs,
  lib,
  ...
}: let
  TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
in {
  home.packages = with pkgs; [
    terragrunt
  ];

  home.shellAliases = {
    tg = "terragrunt --terragrunt-source $(git rev-parse --show-toplevel)";
    tg_plan = "terragrunt run-all plan --terragrunt-source $(git rev-parse --show-toplevel)";
    tg_refresh = "terragrunt run-all refresh --terragrunt-source $(git rev-parse --show-toplevel)";
    tg_init = "terragrunt run-all init --terragrunt-source $(git rev-parse --show-toplevel)";
    tg_apply = "terragrunt run-all apply --terragrunt-source $(git rev-parse --show-toplevel)";
  };

  # home.sessionVariables.TF_PLUGIN_CACHE_DIR = TF_PLUGIN_CACHE_DIR;
  home.activation.terragrunt-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ${TF_PLUGIN_CACHE_DIR} ]; then
      mkdir -p ${TF_PLUGIN_CACHE_DIR}
    fi
  '';
}
