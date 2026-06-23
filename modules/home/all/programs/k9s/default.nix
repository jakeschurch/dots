{
  pkgs,
  config,
  ...
}:
{
  home.packages = [
    (pkgs.symlinkJoin {
      name = "k9s";
      paths = [ pkgs.k9s ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/k9s --set GODEBUG vdso=0
      '';
    })
    pkgs.stern
    pkgs.kubectl-neat
  ];

  home.sessionVariables."K9S_CONFIG_DIR" = "${config.xdg.configHome}/k9s";

  xdg.configFile."k9s" = {
    recursive = true;
    source = ./config;
    force = true;
  };
}
