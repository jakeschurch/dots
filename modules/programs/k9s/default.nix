{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    k9s
  ];

  home.sessionVariables."K9S_CONFIG_DIR" = "${config.xdg.configHome}/k9s";

  xdg.configFile."k9s" = {
    recursive = true;
    source = ./config;
    force = true;
  };
}
