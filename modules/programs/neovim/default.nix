{
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs) lib;
  extraPkgs =
    let
      getPkgs = pkgs': lib.flatten (lib.attrValues pkgs');
      pkgs' = import ./dev-packages.nix pkgs;
    in
    getPkgs pkgs';

  plugman = lib.mkScript {
    pname = "nvim-plugman";
    src = ./plugman.sh;
    propagatedBuildInputs = with pkgs; [
      jq
      gh
    ];
  };

in
{
  home.packages = extraPkgs ++ lib.singleton plugman;

  imports = [
    ./mcphub
  ];

  programs.neovim = {
    package = pkgs.unstable.neovim-nightly;
    enable = true;
    defaultEditor = true;
    extraConfig = builtins.readFile ./init.vim;

    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withRuby = true;
    withPython3 = true;
    vimdiffAlias = true;
    coc.enable = false;
    plugins = pkgs.callPackage ./nvim-plugins.nix { };
  };

  home.sessionVariables = {
    EDITOR = lib.mkForce "nvim";
    PSQL_EDITOR = lib.getExe pkgs.unstable.neovim-nightly;
    VIMRUNTIME = "${pkgs.unstable.neovim-nightly}/share/nvim/runtime";
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

      mapPairsToAttrs = fn: pairs: lib.mapAttrs' fn pairs;

      bindings = {
        "nvim/after" = ./config/after;
        "nvim/lua" = ./config/lua;
        "nvim/snippets" = ./config/snippets;
      };

      inherit (config.lib.file) mkOutOfStoreSymlink;
      inherit (config.home) homeDirectory;

      mkOutOfStoreNeovimSymlink =
        path: mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/programs/neovim/${path}";
    in
    (mapPairsToAttrs mapToXdgConfigFile bindings)
    // {
      "nvim/spell/en.utf-8.add".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add";

      "nvim/spell/en.utf-8.add.spl".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add.spl";
    };
}
