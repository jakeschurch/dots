{
  pkgs,
  config,
  ...
}:
with pkgs;
let
  extraPkgs =
    let
      getPkgs = pkgs': lib.flatten (lib.attrValues pkgs');
      pkgs' = import ./dev-packages.nix pkgs;
    in
    getPkgs pkgs';

  nvimPlugins = import ./nvim-plugins.nix { inherit pkgs; };
  nvimPkgSrc = lib.concatLines (map (x: "vim.opt.runtimepath:append(\"${x.src}\")") nvimPlugins);
in
{
  home.packages = extraPkgs;

  programs.neovim = {
    package = pkgs.neovim-nightly;
    enable = true;
    extraLuaPackages =
      ps: with ps; [
        magick
      ];
    extraPackages = with pkgs; [
      imagemagick
      vscode-langservers-extracted
    ];
    defaultEditor = true;
    extraConfig = ''
      lua <<EOF
      ${nvimPkgSrc}
      EOF
      ${builtins.readFile ./init.vim}
    '';

    viAlias = true;
    vimAlias = true;
    withNodeJs = false;
    withRuby = false;
    withPython3 = true;
    vimdiffAlias = true;
    plugins = nvimPlugins;
  };

  home.sessionVariables = {
    EDITOR = lib.mkForce "nvim";
    PSQL_EDITOR = "nvim";
  };

  xdg.configFile =
    let
      mapToXdgConfigFile = entryName: path: {
        name = entryName;
        value = {
          source = path;
          recursive = true;
        };
      };

      bindings = {
        "nvim/after" = ./config/after;
        "nvim/lua" = ./config/lua;
        "nvim/snippets" = ./config/snippets;
      };

      inherit (config.lib.file) mkOutOfStoreSymlink;
      inherit (config.home) homeDirectory;

      mkOutOfStoreNeovimSymlink =
        path: mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/home/all/programs/neovim/${path}";
    in
    (lib.mapAttrs' mapToXdgConfigFile bindings)
    // {
      "nvim/spell/en.utf-8.add".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add";
      "nvim/spell/en.utf-8.add.spl".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add.spl";
      "nvim/manpager.lua".source = mkOutOfStoreNeovimSymlink "config/manpager.lua";
    };
}
