# User configuration module
{
  flake,
  pkgs,
  lib,
  ...
}:
let
  inherit (flake)
    inputs
    config
    ;
  inherit (inputs) self;
in
{
  options = {
    me = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Your username as shown by `id -un`";
      };
      fullname = lib.mkOption {
        type = lib.types.str;
        description = "Your full name for use in Git config";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Your email for use in Git config";
      };
    };
  };

  config = {
    users.users.${config.me.username} =
      lib.optionalAttrs pkgs.stdenv.isDarwin {
        home = "/Users/${config.me.username}";
      }
      // lib.optionalAttrs pkgs.stdenv.isLinux {
        isNormalUser = true;
      };

    home-manager = {
      users.${config.me.username} = {
        home.username = config.me.username;
        imports = [
          (self + /configurations/home/${config.me.username}.nix)
        ];
      };

      backupFileExtension = "nix-bak";
    };
  };
}
