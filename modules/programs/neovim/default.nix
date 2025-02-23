{
  lib,
  pkgs,
  config,
  ...
}: let
  extraPkgs = let
    getPkgs = pkgs': lib.flatten (lib.attrValues pkgs');
    pkgs' = import ./dev-packages.nix pkgs;
  in
    getPkgs pkgs';
in {
  home.packages = extraPkgs;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;
    extraPackages = extraPkgs;

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

  xdg.configFile = let
    mapToXdgConfigFile = entryName: path: {
      name = entryName;
      value = {
        source = path;
        recursive = true;
      };
    };

    mapPairsToAttrs = fn: pairs: lib.mapAttrs' fn pairs;

    bindings = {
      "nvim/after" = ./config/after;
      "nvim/lua" = ./config/lua;
      "nvim/plugin" = ./config/plugin;
      "nvim/snippets" = ./config/snippets;
    };

    inherit (config.lib.file) mkOutOfStoreSymlink;
    inherit (config.home) homeDirectory;

    mkOutOfStoreNeovimSymlink = path: mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/programs/neovim/${path}";
  in
    (mapPairsToAttrs mapToXdgConfigFile bindings)
    // {
      "nvim/spell/en.utf-8.add".source =
        mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add";

      "nvim/spell/en.utf-8.add.spl".source =
        mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add.spl";
    };
}
