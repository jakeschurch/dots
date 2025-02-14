{
  pkgs,
  python3Packages,
  jq,
  coreutils,
  ...
}: let
  mkScript = import ./mkScript.nix {inherit (pkgs) stdenv;};

  parse-aws-config = mkScript {
    pname = "parse_aws_config";
    src = ./parse_aws_config.py;
    nativeBuildInputs = with python3Packages; [configparser];
    description = "Parse AWS config script";
  };

  aws-login = mkScript {
    pname = "aws-login";
    src = ./aws_profile_login.sh;
    nativeBuildInputs = [jq coreutils parse-aws-config];
    description = "AWS login script";
  };

  fg-commit-wrapper = mkScript {
    pname = "fg-commit";
    src = ./fg-commit-wrapper.sh;
    nativeBuildInputs = [coreutils];
    description = "Prepare commit message for fg features";
  };

  motd = mkScript {
    pname = "motd";
    src = ./motd/motd.sh;
    description = "Message of the day";
  };
in {
  home.packages = [
    parse-aws-config
    aws-login
    fg-commit-wrapper
    motd
  ];

  home.file.".config/motd/quotes.json".source = ./motd/quotes.json;
}
