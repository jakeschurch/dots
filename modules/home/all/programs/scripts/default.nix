{
  pkgs,
  ...
}:
let

  inherit (pkgs) lib;
  inherit (lib) mkScript;
  inherit (pkgs)
    python3
    asciinema
    asciinema-agg
    ffmpeg
    jq
    coreutils
    mosh
    coreutils-prefixed
    gnutar
    gzip
    bzip2
    xz
    unzip
    p7zip
    unrar
    zstd
    wtype
    ;

  # spell-check-env-vars = lib.mkScript {
  #   pname = "spell-check-env-vars";
  #   src = ./spell_check_env_vars.py;
  #   propagatedBuildInputs = lib.singleton (
  #     python3.withPackages (
  #       ps: with ps; [
  #         pyspellchecker
  #       ]
  #     )
  #   );
  #   description = "Spell check env vars";
  # };

  record-gif = mkScript {
    pname = "record-gif";
    src = ./record-gif.sh;
    propagatedBuildInputs = [
      asciinema
      asciinema-agg
    ];
    description = "Record a gif";
  };

  gif2mp4 = mkScript {
    pname = "gif2vid";
    src = ./gif2vid.sh;
    propagatedBuildInputs = [ ffmpeg ];
    description = "Make mp4 from gif";
  };

  parse-aws-config = mkScript {
    pname = "parse_aws_config";
    src = ./parse_aws_config.py;
    propagatedBuildInputs = lib.singleton (
      python3.withPackages (
        ps: with ps; [
          configparser
        ]
      )
    );

    description = "Parse AWS config script";
  };

  aws-login = mkScript {
    pname = "aws-login";
    src = ./aws_profile_login.sh;
    propagatedBuildInputs = [
      jq
      coreutils
      parse-aws-config
    ];
    description = "AWS login script";
  };

  fg-commit-wrapper = mkScript {
    pname = "fg-commit";
    src = ./fg-commit-wrapper.sh;
    propagatedBuildInputs = [ coreutils ];
    description = "Prepare commit message for fg features";
  };

  motd = mkScript {
    pname = "motd";
    src = ./motd/motd.sh;
    description = "Message of the day";
  };

  ssh-wrapper = mkScript {
    pname = "ssh-wrapper";
    src = ./ssh-wrapper.sh;
    description = "ssh wrapper";
    propagatedBuildInputs = [ mosh ];
  };

  nvim-wrapper = mkScript {
    pname = "nvim-wrapper";
    src = ./nvim-wrapper.sh;
    description = "neovim wrapper";
    propagatedBuildInputs = [ coreutils-prefixed ];
  };

  extract = mkScript {
    pname = "extract";
    src = ./extract.sh;
    propagatedBuildInputs = [
      gnutar
      gzip
      bzip2
      xz
      unzip
      p7zip
      unrar
      zstd
    ];
    description = "Extract any archive format";
  };

  clipboard-key = mkScript {
    pname = "clipboard-key";
    src = ./clipboard-key.sh;
    propagatedBuildInputs = [
      jq
      wtype
      pkgs.cliphist
    ];
    description = "Route Super+C/V to the right clipboard shortcut per app";
  };

  cliphist-pick = mkScript {
    pname = "cliphist-pick";
    src = ./cliphist-pick.sh;
    propagatedBuildInputs = [
      jq
      wtype
      pkgs.cliphist
    ];
    description = "Open cliphist picker in floating wezterm and paste selection";
  };

  cliphist-pic = mkScript {
    pname = "cliphist-pic";
    src = ./cliphist-pic.sh;
    propagatedBuildInputs = [
      jq
      wtype
      pkgs.cliphist
    ];
    description = "Open cliphist image picker in floating wezterm and paste selection";
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
    extract
    clipboard-key
    cliphist-pick
    cliphist-pic
    # spell-check-env-vars
  ];

  home.file.".config/motd/quotes.json".source = ./motd/quotes.json;
}
