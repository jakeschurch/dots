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
    withPython3 = false;
    vimdiffAlias = true;
    plugins = nvimPlugins;
  };

  home.sessionVariables = {
    EDITOR = lib.mkForce "nvim";
    PSQL_EDITOR = "nvim";
  };

  # Everything under config/ is symlinked back out of the store so edits are
  # live — no rebuild between changing a lua file and restarting nvim.
  xdg.configFile =
    let
      inherit (config.lib.file) mkOutOfStoreSymlink;
      inherit (config.home) homeDirectory;

      mkOutOfStoreNeovimSymlink =
        path: mkOutOfStoreSymlink "${homeDirectory}/.dots/modules/home/all/programs/neovim/${path}";
    in
    {
      "nvim/after".source = mkOutOfStoreNeovimSymlink "config/after";
      "nvim/lua".source = mkOutOfStoreNeovimSymlink "config/lua";
      "nvim/snippets".source = mkOutOfStoreNeovimSymlink "config/snippets";
      "nvim/spell/en.utf-8.add".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add";
      "nvim/spell/en.utf-8.add.spl".source = mkOutOfStoreNeovimSymlink "config/spell/en.utf-8.add.spl";
      "nvim/manpager.lua".source = mkOutOfStoreNeovimSymlink "config/manpager.lua";
    };
}
