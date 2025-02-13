{
  callPackage,
  python3Packages,
  jq,
  coreutils,
  ...
}: let
  mkScript = callPackage ./mkScript.nix {};

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
in [
  parse-aws-config
  aws-login
  fg-commit-wrapper
]
