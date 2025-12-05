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
      plugins = map pluginGit vimPluginsToFetch;
    in
    map (
      x:
      x.overrideAttrs {
        doCheck = false;
      }
    ) plugins;

  nix-nvim-plugins =
    with pkgs.vimPlugins;
    [
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
