{ pkgs, ... }:
let

  # Plugins not in nixpkgs vimPlugins. Each is a flake package under packages/
  # with a nix-update updateScript (run `nix-update --flake <name>`, or bump all
  # via `nix run .#update-packages`).
  custom-sourced-nvim-plugins = with pkgs; [
    ghlite-nvim
    vim-symlink
    none-ls-extras-nvim
    none-ls-shellcheck-nvim
    vim-venter
    presenting-nvim
    gitgood-lua
    none-ls-nvim-patched
  ];

  nix-nvim-plugins =
    with pkgs.vimPlugins;
    [
      # Migrated from versions.json/plug.sh — now tracked by nixpkgs
      otter-nvim
      blink-emoji-nvim
      oil-lsp-diagnostics-nvim
      codecompanion-nvim
      fzf-wrapper
      blink-copilot
      colorful-menu-nvim
      luasnip

      fzf-lua
      rainbow-delimiters-nvim
      nvim-notify

      guess-indent-nvim

      blink-cmp
      codecompanion-history-nvim
      snacks-nvim
      blink-pairs

      noice-nvim

      nvim-dap-python
      nvim-lspconfig
      copilot-vim
      copilot-lua

      img-clip-nvim
      image-nvim

      nvim-autopairs
      vimwiki
      vim-git
      vim-fugitive
      vim-dispatch

      oil-git-status-nvim
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

      telescope-nvim
      telescope-dap-nvim
      vim-matchup
      grug-far-nvim

      nvim-nio

      lualine-nvim

      popup-nvim

      plenary-nvim

      lsp-status-nvim

      nvim-lspconfig

      nvim-dap

      indent-blankline-nvim

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

      nvim-ts-context-commentstring

      img-clip-nvim
      # nvim-treesitter-textobjects-patched
      dressing-nvim
      nui-nvim

      plenary-nvim
      trouble-nvim
      render-markdown-nvim

      diffview-nvim

      nvim-colorizer-lua

      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
    ];

  treesitter-plugins = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

  allPlugins =
    nix-nvim-plugins ++ custom-sourced-nvim-plugins ++ pkgs.lib.singleton treesitter-plugins;
in
allPlugins
