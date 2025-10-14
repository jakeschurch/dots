{
  flake,
  ...
}:
{
  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults pwfeedback

      @wheel    ALL = (ALL) NOPASSWD: ALL
      ${flake.config.me.username}    ALL = (ALL) NOPASSWD: ALL
    '';
  };
}
