pkgs: {
  python = with pkgs; [
    pipenv
    pyright
    pylint
    (python312.withPackages (
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
    nodePackages.prettier
    nodePackages.eslint
    nodePackages.typescript
    vtsls
    vscode-langservers-extracted
    nodePackages.webpack
    nodePackages.webpack-cli

    vscode-js-debug

    # nodePackages.neovim
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
    nodePackages.dockerfile-language-server-nodejs
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
  ];

  markdown = with pkgs.python3Packages; [
    mdformat
    mdformat-gfm
    mdformat-gfm-alerts
    mdformat-admon
    mdformat-frontmatter
    mdformat-footnote
    mdformat-simple-breaks
    mdformat-tables
    mdformat-beautysh
  ];

  html = with pkgs; [
    emmet-ls
  ];

  misc = with pkgs; [
    mcp-hub

    ast-grep
    tree-sitter
    codespell
    nodePackages.yaml-language-server
    actionlint
    yamllint
    nodePackages.vscode-json-languageserver
    semgrep
    hadolint
    helm-ls
  ];

  sql = with pkgs; [
    sqlfluff
  ];
}
