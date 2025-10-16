pkgs: {
  python = with pkgs; [
    pipenv
    pyright
    pylint
    (python3.withPackages (
      ps: with ps; [
        debugpy
        setuptools # Required by pylama for some reason
        proselint
        poetry-core
        toolz
        pylama
        black
        isort
        pip
        flake8
        neovim
        mypy
      ]
    ))
  ];

  elixir = with pkgs; [
    elixir_1_18
    (elixir-ls.override {
      elixir = elixir_1_18;
    })
  ];

  nix = with pkgs; [
    nixfmt-rfc-style
    statix
    alejandra
    deadnix
    nil
  ];

  typescript = with pkgs; [
    typescript
    prettier-d-slim
    nodePackages.eslint
    nodePackages.typescript
    vtsls
    vscode-langservers-extracted
    vscode-js-debug
  ];

  shell = with pkgs; [
    shfmt
    shellcheck
    shellharden
    bash-language-server
  ];

  lua = with pkgs; [
    luajitPackages.fzf-lua
    luajitPackages.jsregexp
    luajitPackages.plenary-nvim
    luajitPackages.tiktoken_core
    luarocks
    luaPackages.luafilesystem
    lua53Packages.digestif
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
    dockerfile-language-server
  ];

  hcl = with pkgs; [
    terraform-ls
    terraform-docs
    tflint
    # tfenv
    tfsec
    hclfmt
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
    golint
    golines
    delve
    gofumpt
    goimports-reviser
    golangci-lint
  ];

  markdown = with pkgs; [
    vale-ls
  ];

  html = with pkgs; [
    emmet-ls
  ];

  misc = with pkgs; [
    ast-grep
    tree-sitter
    codespell
    nodePackages.yaml-language-server
    # actionlint
    yamllint
    semgrep
    hadolint
    helm-ls
    regols
    regal
  ];

  sql = with pkgs; [
    sqlfluff
  ];
}
