{lib}: let
  inherit (builtins) length filter concatStringsSep map;
  inherit (lib.lists) last;
  inherit (lib.strings) splitString;
  inherit (lib.filesystem) listFilesRecursive;

  getFileExt = x: let
    parts = splitString "." x;
  in
    if length parts > 0
    then last parts
    else null;

  isFiletype = ft: x: getFileExt x == ft;
  isLuaFile = isFiletype "lua";
  isVimFile = isFiletype "vim";

  files = let
    pluginFiles = listFilesRecursive ./plugin;
  in {
    lua = filter isLuaFile pluginFiles;
    vim = filter isVimFile pluginFiles;
  };

  fileConfigs = {
    vim = concatStringsSep "\n" (map lib.fileContents files.vim);
    lua = let
      luaFileContents = concatStringsSep "\n" (map lib.fileContents files.lua);
    in ''
      lua <<EOF
        ${luaFileContents}
      EOF
    '';
  };
in
  builtins.concatStringsSep "\n" [
    fileConfigs.lua
    fileConfigs.vim
  ]
