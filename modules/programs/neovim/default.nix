{
  lib,
  pkgs,
  config,
  ...
}: let
  luaConfig = x: ''
    lua <<EOF
      ${x}
    EOF
  '';
  myPkgs = import ./devPackages.nix {inherit pkgs;};

  # myPerlPackages = lib.attrValues myPkgs.myPerlPackages;
  devPackages = lib.flatten (lib.attrValues myPkgs.devPackages);

  # installs a vim plugin from git with a given tag / branch
  pluginGit = rev: ref: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = rev;
      src = builtins.fetchGit {
        inherit rev ref;
        url = "https://github.com/${repo}.git";
      };
    };

  versionLockfile = with builtins; file: fromJSON (readFile file);
  generatePluginRevs = map (x: (pluginGit x.rev x.ref x.name)) (versionLockfile ./versions.json);

  readFiles = let
    inherit (builtins) readFile foldl' toString map filter split;

    getFileExtension = file:
      foldl' (_acc: item: item) "" (split "\\." (toString file));

    confFiles = dirs: lib.lists.flatten (map lib.filesystem.listFilesRecursive dirs);
    isLuaFile = file: (getFileExtension file) == "lua";
    isVimFile = file: (getFileExtension file) == "vim";

    mkVimConfig = files:
      lib.strings.concatStringsSep "\n" (
        map readFile
        (filter isVimFile files)
      );

    mkLuaConfig = files:
      luaConfig (lib.strings.concatStringsSep "\n" (
        map readFile
        (filter isLuaFile files)
      ));

    mkConfig = files: mkLuaConfig files + "\n" + mkVimConfig files;
  in
    mkConfig (confFiles [./plugin]);

  treesitter-plugins = pkgs.vimPlugins.nvim-treesitter.withPlugins (ts-plugins:
    with ts-plugins; [
      awk
      bash
      comment
      css
      dhall
      dockerfile
      elixir
      embedded_template
      func
      git_config
      git_rebase
      gitcommit
      gitignore
      # go
      graphql
      haskell
      hcl
      heex
      html
      javascript
      jq
      json
      latex
      lua
      make
      markdown
      markdown_inline
      mermaid
      nix
      passwd
      promql
      python
      regex
      sql
      ssh_config
      terraform
      typescript
      vim
      vimdoc
      yaml
      yuck
    ]);
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    PSQL_EDITOR = "nvim";
  };

  xdg.configFile = {
    "nvim".source = ./config;
    "nvim".recursive = true;
    "nvim/spell/en.utf-8.add".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add";
    "nvim/spell/en.utf-8.add.spl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add.spl";
  };

  home.packages = devPackages;

  programs.neovim = {
    defaultEditor = true;
    package = pkgs.neovim;
    # TODO: extraPackages = myPerlPackages;
    extraConfig =
      luaConfig ''
        -- lua
        local status, ts_install = pcall(require, "nvim-treesitter.install")
        ts_install.compilers = { "${pkgs.gcc}/bin/gcc" }
      ''
      + builtins.readFile ./init.vim
      + readFiles;
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    vimdiffAlias = true;
    coc.enable = false;
    plugins =
      generatePluginRevs
      ++ [
        treesitter-plugins
        pkgs.vimPlugins.telescope-fzf-native-nvim
      ];
  };
}
