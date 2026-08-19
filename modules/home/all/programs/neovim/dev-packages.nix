pkgs: {
  python = with pkgs; [
    pipenv
    pyright
    # ruff covers formatting, import sorting and linting in one binary.
    ruff
  ];

  elixir = with pkgs; [
    beamPackages.elixir_1_19
    expert
  ];

  nix = with pkgs; [
    nixd
    nixfmt
    statix
    alejandra
    deadnix
  ];

  typescript = with pkgs; [
    typescript
    prettier
    prettier-d-slim
    eslint
    typescript
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
    luajitPackages.magick
    luajitPackages.jsregexp
    luajitPackages.plenary-nvim
    luajitPackages.tiktoken_core
    luarocks
    luaPackages.luafilesystem
    lua53Packages.digestif
    lua-language-server
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
    # tfsec was archived upstream and folded into trivy.
    trivy
    hclfmt
    packer
  ];

  ansible = with pkgs; [
    ansible
    # ansible-doctor
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
    golines
    delve
    gofumpt
    goimports-reviser
    golangci-lint
  ];

  markdown = with pkgs; [
    vale-ls

    # Plugins have to share mdformat's python env or it cannot discover them;
    # installed side by side they were silently inert.
    (mdformat.withPlugins (
      ps: with ps; [
        mdformat-admon
        mdformat-beautysh
        mdformat-footnote
        mdformat-frontmatter
        mdformat-gfm
        mdformat-gfm-alerts
        mdformat-mkdocs
        mdformat-myst
        mdformat-nix-alejandra
        mdformat-simple-breaks
      ]
    ))
  ];

  html = with pkgs; [
    emmet-ls
    html-tidy
    stylelint
  ];

  misc = with pkgs; [
    ast-grep
    tree-sitter
    lazygit
    ghostscript
    codespell
    yaml-language-server
    actionlint
    yamllint
    # semgrep
    hadolint
    helm-ls
    regols
    regal
  ];

  sql = with pkgs; [
    sqlfluff
  ];
}
