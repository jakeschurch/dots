{pkgs, ...}: let
  inherit (pkgs) lib;
in {
  myPerlPackages = with pkgs;
  with perlPackages; rec {
    FutureIO = buildPerlModule {
      pname = "Future-IO";
      version = "0.11";
      src = fetchurl {
        url = "mirror://cpan/authors/id/P/PE/PEVANS/Future-IO-0.11.tar.gz";
        sha256 = "75533626f81f768c5f231c9702106c25b5772a8b6995caa2c58bcc4acc9107c9";
      };
      buildInputs = [TestIdentity];
      propagatedBuildInputs = [Future StructDumb];
      meta = {
        description = "Future-returning IO methods";
        license = with lib.licenses; [artistic1 gpl1Plus];
      };
    };

    IOAsync = buildPerlModule {
      pname = "IO-Async";
      version = "0.802";
      src = fetchurl {
        url = "mirror://cpan/authors/id/P/PE/PEVANS/IO-Async-0.802.tar.gz";
        sha256 = "e582731577767c47eac435ef2904663d4a750b0e6802a4a6189a37f0cb308738";
      };
      buildInputs = [FutureIO TestFatal TestIdentity TestMetricsAny TestRefcount];
      propagatedBuildInputs = [Future StructDumb];
      meta = {
        description = "Asynchronous event-driven programming";
        license = with lib.licenses; [artistic1 gpl1Plus];
      };
    };

    EvalSafe =
      buildPerlPackage
      {
        pname = "Eval-Safe";
        version = "0.02";
        src = fetchurl {
          url = "mirror://cpan/authors/id/M/MA/MATHIAS/Eval-Safe/Eval-Safe-0.02.tar.gz";
          sha256 = "55a52c233e2dae86113f9f19b34f617edcfc8416f9bece671267bd1811b12111";
        };
        outputs = ["out" "dev"]; # no devdoc
        meta = {
          description = "Simplified safe evaluation of Perl code";
          license = lib.licenses.mit;
        };
      };

    MsgPackRaw = buildPerlPackage {
      pname = "MsgPack-Raw";
      version = "0.05";
      src = fetchurl {
        url = "mirror://cpan/authors/id/J/JA/JACQUESG/MsgPack-Raw-0.05.tar.gz";
        sha256 = "8559e2b64cd98d99abc666edf2a4c8724c9534612616af11f4eb0bbd0d422dac";
      };
      buildInputs = [TestPod TestPodCoverage];
      meta = {
        description = "Perl bindings to the msgpack C library";
        license = with lib.licenses; [artistic1 gpl1Plus];
      };
    };

    NeovimExt = buildPerlPackage {
      pname = "Neovim-Ext";
      version = "0.06";
      src = fetchurl {
        url = "mirror://cpan/authors/id/J/JA/JACQUESG/Neovim-Ext-0.06.tar.gz";
        sha256 = "6d2ceb3062c96737dba556cb20463130fc4006871b25b7c4f66cd3819d4504b8";
      };
      buildInputs = with pkgs.perlPackages; [ArchiveZip FileSlurper FileWhich ProcBackground TestPod TestPodCoverage];
      propagatedBuildInputs = [
        ClassAccessor

        IOAsync
        MsgPackRaw
      ];
      meta = {
        description = "Perl bindings for neovim";
        license = with lib.licenses; [artistic1 gpl1Plus];
      };
    };
  };

  devPackages = {
    python = with pkgs; [
      pipenv
      pyright
      pylint
      (python311.withPackages (ps:
        with ps; [
          setuptools # Required by pylama for some reason
          proselint
          toolz
          pylama
          black
          isort
          pip
          flake8
          neovim
          mypy
        ]))
    ];

    elixir = with pkgs; [
      elixir_1_16
      elixir-ls
    ];

    nix = with pkgs; [
      nixfmt
      statix
      alejandra
      deadnix
      nil
    ];

    typescript = with pkgs; [
      typescript
      prettier-d-slim
      nodePackages.prettier
      nodePackages.eslint
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.webpack
      nodePackages.webpack-cli

      nodejs
      nodePackages.neovim
    ];

    shell = with pkgs; [
      shfmt
      shellcheck
      shellharden
      nodePackages.bash-language-server
    ];

    lua = with pkgs; [
      lua5_4
      luarocks
      sumneko-lua-language-server
      stylua
    ];

    haskell = with pkgs; [
      ghc
      haskell-language-server
      haskellPackages.cabal-fmt
    ];

    prose = with pkgs; [
      codespell
      gitlint
      vale
    ];

    docker = with pkgs; [
      nodePackages.dockerfile-language-server-nodejs
    ];

    hcl = with pkgs; [
      terraform-ls
      terragrunt
      terraform-docs
      tflint
      tfenv
      packer
    ];

    ansible = with pkgs; [
      ansible
      ansible-doctor
      ansible-lint
    ];

    rust = with pkgs; [
      rustc
      cargo
      rustfmt

      rust-analyzer
    ];

    go = with pkgs; [
      go
      gopls
    ];

    html = with pkgs; [
      emmet-ls
    ];

    misc = with pkgs; [
      tree-sitter

      codespell
      nodePackages.yaml-language-server
      yamllint
      nodePackages.vscode-json-languageserver
    ];

    sql = with pkgs; [
      sqlfluff
    ];
  };
}
