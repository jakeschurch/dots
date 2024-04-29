{pkgs, ...}: {
  home.packages = with pkgs; [
    k9s
  ];

  xdg.configFile."k9s" = {
    recursive = true;
    source = ./config;
    force = true;
  };
}
