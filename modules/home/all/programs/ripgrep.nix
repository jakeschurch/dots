{ pkgs, lib, ... }:
{
  home = {
    packages = [
      (pkgs.ripgrep.override { withPCRE2 = true; })
    ];

    file.".rgignore".text = import ../../../../config/ignore.nix { inherit lib; };

    file.".ripgreprc".text = ''
      --hidden
      --pcre2
      --no-heading
      --smart-case
    '';
  };
}
