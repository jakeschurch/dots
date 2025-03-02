{ pkgs, ... }:
with pkgs;
let
  record-gif = lib.mkScript {
    pname = "record-gif";
    src = ./record-gif.sh;
    propagatedBuildInputs = [
      asciinema
      asciinema-agg
    ];
    description = "Record a gif";
  };

  gif2mp4 = lib.mkScript {
    pname = "gif2vid";
    src = ./gif2vid.sh;
    propagatedBuildInputs = [ ffmpeg ];
    description = "Make mp4 from gif";
  };

  parse-aws-config = lib.mkScript {
    pname = "parse_aws_config";
    src = ./parse_aws_config.py;
    propagatedBuildInputs = with python3Packages; [ configparser ];
    description = "Parse AWS config script";
  };

  aws-login = lib.mkScript {
    pname = "aws-login";
    src = ./aws_profile_login.sh;
    propagatedBuildInputs = [
      jq
      coreutils
      parse-aws-config
    ];
    description = "AWS login script";
  };

  fg-commit-wrapper = lib.mkScript {
    pname = "fg-commit";
    src = ./fg-commit-wrapper.sh;
    propagatedBuildInputs = [ coreutils ];
    description = "Prepare commit message for fg features";
  };

  motd = lib.mkScript {
    pname = "motd";
    src = ./motd/motd.sh;
    description = "Message of the day";
  };

  ssh-wrapper = lib.mkScript {
    pname = "ssh-wrapper";
    src = ./ssh-wrapper.sh;
    description = "ssh wrapper";
    propagatedBuildInputs = [ mosh ];
  };

  nvim-wrapper = lib.mkScript {
    pname = "nvim-wrapper";
    src = ./nvim-wrapper.sh;
    description = "neovim wrapper";
    propagatedBuildInputs = [ coreutils-prefixed ];
  };
in
{
  home.packages = [
    parse-aws-config
    aws-login
    fg-commit-wrapper
    motd
    ssh-wrapper
    nvim-wrapper
    gif2mp4
    record-gif
  ];

  home.file.".config/motd/quotes.json".source = ./motd/quotes.json;
}
