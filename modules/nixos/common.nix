{ flake, ... }:
let
  inherit (flake) config;
in
{
  security.sudo.extraConfig = ''
    @wheel    ALL = (ALL) NOPASSWD: ALL
    ${config.me.username}    ALL = (ALL) NOPASSWD: ALL

    Defaults pwfeedback
  '';
}
