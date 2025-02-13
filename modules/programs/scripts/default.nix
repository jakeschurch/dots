{
  pkgs,
  python3Packages,
  jq,
  coreutils,
  ...
}: let
  parse_aws_config = pkgs.stdenv.mkDerivation rec {
    pname = "parse_aws_config";
    version = "0.0";

    src = ./parse_aws_config.py; # Path to your Python script

    nativeBuildInputs = with python3Packages; [configparser];

    # Ensure the script is executable
    installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/parse_aws_config
      chmod +x $out/bin/parse_aws_config
    '';

    unpackPhase = "true";

    meta = {
      description = "Parse AWS config script";
    };
  };

  aws-login = pkgs.stdenv.mkDerivation rec {
    pname = "aws-login";
    version = "0.0";

    # The source Python file (no unpacking, just use the file directly)
    src = ./aws_profile_login.sh;

    # Dependencies for the environment
    nativeBuildInputs = [jq coreutils parse_aws_config];

    # Skip the unpacking phase
    unpackPhase = "true";

    # Install phase: Copy the Python script to $out/bin and make it executable
    installPhase = ''
      mkdir -p $out/bin
      cp ${src} $out/bin/aws-login

      # Make sure the script is executable
      chmod +x $out/bin/aws-login
    '';

    meta = {
      description = "AWS login script";
    };
  };
in [
  parse_aws_config
  aws-login
]
