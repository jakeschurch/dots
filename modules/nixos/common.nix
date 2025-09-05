{ flake, ... }:
{
  security.sudo.extraConfig = ''
    @wheel    ALL = (ALL) NOPASSWD: ALL
    ${flake.config.me.username}    ALL = (ALL) NOPASSWD: ALL

    Defaults pwfeedback
  '';
}
