{
  flake,
  pkgs,
  lib,
  ...
}:
{
  security.sudo = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    enable = true;
    wheelNeedsPassword = false;
    extraConfig = ''
      Defaults pwfeedback
    '';
    extraRules = [
      {
        users = [ flake.config.me.username ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
