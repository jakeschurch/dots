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

  # home.sessionVariables.TF_PLUGIN_CACHE_DIR = TF_PLUGIN_CACHE_DIR;
  home.activation.terragrunt-setup = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ${TF_PLUGIN_CACHE_DIR} ]; then
      mkdir -p ${TF_PLUGIN_CACHE_DIR}
    fi
  '';
}
