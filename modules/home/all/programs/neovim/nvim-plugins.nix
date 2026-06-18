{ pkgs, ... }:
let

  none-ls-nvim-patched = pkgs.vimUtils.buildVimPlugin {
    pname = "none-ls-nvim";
    version = "git-HEAD";
    src = pkgs.fetchFromGitHub {
      owner = "ulisses-cruz";
      repo = "none-ls.nvim";
      rev = "main"; # Or a specific commit SHA
      sha256 = "sha256-nZvUWJpd/uTOwMQpy2ZGMHZ32z9M+IVB1ME4dvDFz8g=";
    };
  };

  # PR review, fugitive-style. gh's store path is baked into gh_cmd so the plugin
  # carries its own gh (gh auth still comes from the user env).
  gitgood-lua = pkgs.vimUtils.buildVimPlugin {
    pname = "gitgood-lua";
    version = "49922bc";
    src = pkgs.fetchFromGitHub {
      owner = "jakeschurch";
      repo = "gitgood.lua";
      rev = "49922bc30d6f9bd3da74b99800f60c85dc5504cc";
      sha256 = "sha256-MLTsbf1laBgY9KgC27wgk0Dogr+CsS8MMWzHQy9iqdI=";
    };
    postPatch = ''
      substituteInPlace lua/gitgood/config.lua \
        --replace-fail 'gh_cmd = "gh"' 'gh_cmd = "${pkgs.lib.getExe pkgs.gh}"'
    '';
    doCheck = false;
  };

  # Plugins not in nixpkgs vimPlugins. Each is a flake package under packages/
  # with a nix-update updateScript (run `nix-update --flake <name>`).
  custom-sourced-nvim-plugins = with pkgs; [
    ghlite-nvim
    vim-symlink
    none-ls-extras-nvim
    none-ls-shellcheck-nvim
    vim-venter
    presenting-nvim
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
      gitgood-lua

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
    ]
    ++ pkgs.lib.singleton none-ls-nvim-patched;

  treesitter-plugins = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

  allPlugins =
    nix-nvim-plugins ++ custom-sourced-nvim-plugins ++ pkgs.lib.singleton treesitter-plugins;
in
allPlugins
