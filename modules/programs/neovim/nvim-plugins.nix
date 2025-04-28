{ pkgs, ... }:
let
  custom-sourced-nvim-plugins =
    let
      pluginGit =
        {
          rev,
          owner,
          repo,
          sha256,
          ...
        }:
        pkgs.vimUtils.buildVimPlugin {
          pname = pkgs.lib.strings.sanitizeDerivationName repo;
          version = rev;
          src = pkgs.fetchFromGitHub {
            inherit
              owner
              repo
              rev
              sha256
              ;
          };
        };

      readJsonFile = with builtins; file: fromJSON (readFile file);
      vimPluginsToFetch = readJsonFile ./versions.json;
    in
    map pluginGit vimPluginsToFetch;

  # codecompanion-nvim-next = pkgs.unstable.vimPlugins.codecompanion-nvim.overrideAttrs (_: {
  #   src = pkgs.fetchFromGitHub {
  #     owner = "olimorris";
  #     repo = "codecompanion.nvim";
  #     rev = "v14.2.2";
  #     sha256 = "sha256-LKC0y6/+6PWlIIWpfBdfaTFVnndFvk7id2kBMwrIlKQ=";
  #   };
  # });

  nix-nvim-plugins = with pkgs.unstable.vimPlugins; [
    fzf-lua

    blink-cmp
    snacks-nvim
    blink-pairs

    noice-nvim
    nvim-notify

    codecompanion-nvim
    nvim-dap-python
    nvim-lspconfig
    copilot-lua
    nvim-autopairs
    vimwiki
    vim-git
    vim-fugitive
    vim-dispatch
    oil-nvim
    nvim-dap-ui

    vim-unimpaired

    vim-repeat

    nvim-dap-virtual-text

    gitlinker-nvim

    nvim-dap-ui

    friendly-snippets

    octo-nvim

    hop-nvim

    lspkind-nvim

    lspsaga-nvim

    playground

    telescope-nvim
    telescope-dap-nvim
    grug-far-nvim

    nvim-nio

    lualine-nvim

    popup-nvim

    plenary-nvim

    lsp-status-nvim

    nvim-lspconfig

    nvim-dap

    indent-blankline-nvim

    impatient-nvim

    gitsigns-nvim

    nvim-surround

    nvim-web-devicons

    vim-emoji

    virtual-types-nvim

    alpha-nvim

    which-key-nvim

    gruvbox-nvim

    yuck-vim

    kommentary

    toggleterm-nvim

    luasnip
    nvim-ts-context-commentstring

    img-clip-nvim
    nvim-treesitter-textobjects
    nvim-treesitter-textsubjects
    none-ls-nvim

    dressing-nvim
    nui-nvim

    plenary-nvim
    trouble-nvim
    render-markdown-nvim

    otter-nvim

    diffview-nvim
  ];

  treesitter-plugins = pkgs.unstable.vimPlugins.nvim-treesitter.withAllGrammars;
in
nix-nvim-plugins ++ custom-sourced-nvim-plugins ++ pkgs.lib.singleton treesitter-plugins
