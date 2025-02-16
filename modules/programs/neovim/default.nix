{
  lib,
  pkgs,
  config,
  ...
}: {
  home.packages = let
    getPkgs = pkgs': lib.flatten (lib.attrValues pkgs');
    pkgs' = import ./dev-packages.nix pkgs;
  in
    getPkgs pkgs';

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;

    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    vimdiffAlias = true;
    coc.enable = false;
    plugins = import ./nvim-plugins.nix pkgs;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    PSQL_EDITOR = "nvim";
    VIMRUNTIME = "${pkgs.neovim-nightly}/share/nvim/runtime";
  };

  xdg.configFile = with config.lib.file;
  with config.home; {
    "nvim/lua/plugin" = {
      source = ./plugin;
      recursive = true;
    };

    nvim = {
      source = ./config;
      recursive = true;
    };

    "nvim/spell/en.utf-8.add".source =
      mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add";

    "nvim/spell/en.utf-8.add.spl".source =
      mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add.spl";
  };
}
