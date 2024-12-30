{
  lib,
  pkgs,
  config,
  ...
}: let
  myPkgs = import ./devPackages.nix {inherit pkgs;};

  pluginGit = rev: ref: repo:
    pkgs.vimUtils.buildVimPlugin {
      pname = "${lib.strings.sanitizeDerivationName repo}";
      version = rev;
      src = builtins.fetchGit {
        inherit rev ref;
        url = "https://github.com/${repo}.git";
      };
    };

  pluginVersionLock = let
    readJsonFile = with builtins; file: fromJSON (readFile file);
  in
    map (x: (pluginGit x.rev x.ref x.name)) (readJsonFile ./versions.json);

  # myPerlPackages = lib.attrValues myPkgs.myPerlPackages;
  devPackages = lib.flatten (lib.attrValues myPkgs.devPackages);

  treesitter-plugins = pkgs.unstable.vimPlugins.nvim-treesitter.withPlugins (ts-plugins:
    with ts-plugins; [
      awk
      bash
      comment
      css
      desktop
      dhall
      diff
      dockerfile
      elixir
      embedded_template
      func
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitcommit
      gitignore
      go
      gomod
      graphql
      haskell
      hcl
      heex
      heex
      html
      html
      javascript
      jq
      jq
      json
      latex
      lua
      luadoc
      make
      make
      markdown
      markdown_inline
      mermaid
      ninja
      nix
      passwd
      promql
      python
      regex
      rust
      sql
      ssh_config
      sxhkdrc
      templ
      terraform
      toml
      tsx
      typescript
      vim
      vimdoc
      yaml
      yuck
    ]);
in {
  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "nvim +Man!";
    PSQL_EDITOR = "nvim";
    VIMRUNTIME = "${pkgs.neovim}/share/nvim/runtime";
  };

  xdg.configFile = {
    "nvim/lua/plugin".source = ./plugin;
    "nvim/lua/plugin".recursive = true;
    "nvim".source = ./config;
    "nvim".recursive = true;
    "nvim/spell/en.utf-8.add".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add";
    "nvim/spell/en.utf-8.add.spl".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dots/modules/programs/neovim/spell/en.utf-8.add.spl";
  };

  home.packages = devPackages;

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    defaultEditor = true;
    # TODO: extraPackages = myPerlPackages;
    extraConfig = builtins.concatStringsSep "\n" [
      (builtins.readFile ./init.vim)
      ''
        lua <<EOF
          -- lua
          local status, ts_install = pcall(require, "nvim-treesitter.install")
          ts_install.compilers = { "${pkgs.gcc}/bin/gcc" }
        EOF
      ''
    ];

    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    vimdiffAlias = true;
    coc.enable = false;
    plugins =
      pluginVersionLock
      ++ [
        treesitter-plugins
        pkgs.unstable.vimPlugins.telescope-fzf-native-nvim
      ];
  };
}
