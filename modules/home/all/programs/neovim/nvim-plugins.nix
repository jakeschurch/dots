{ pkgs, ... }:
let

  # Plugins not in nixpkgs vimPlugins. Each is a flake package under packages/
  # with a nix-update updateScript (run `nix-update --flake <name>`, or bump all
  # via `nix run .#update-packages`).
  custom-sourced-nvim-plugins = with pkgs; [
    vim-symlink
    none-ls-extras-nvim
    none-ls-shellcheck-nvim
    vim-venter
    presenting-nvim
    gitgood-lua
    none-ls-nvim-patched
  ];

  nix-nvim-plugins = with pkgs.vimPlugins; [
    # Completion
    blink-cmp
    blink-copilot
    blink-emoji-nvim
    blink-pairs
    colorful-menu-nvim
    lspkind-nvim
    luasnip
    friendly-snippets
    nvim-autopairs

    # LSP / diagnostics
    nvim-lspconfig
    lspsaga-nvim
    otter-nvim
    tiny-inline-diagnostic-nvim
    trouble-nvim

    # Debug
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    nvim-nio

    # Git
    vim-fugitive
    vim-git
    gitsigns-nvim
    gitlinker-nvim
    diffview-nvim
    octo-nvim

    # Files / pickers
    fzf-lua
    oil-nvim
    oil-git-status-nvim
    oil-lsp-diagnostics-nvim
    grug-far-nvim

    # UI
    alpha-nvim
    gruvbox-nvim
    lualine-nvim
    noice-nvim
    nui-nvim
    nvim-web-devicons
    snacks-nvim
    which-key-nvim
    toggleterm-nvim
    nvim-colorizer-lua
    rainbow-delimiters-nvim
    image-nvim
    img-clip-nvim

    # Editing
    hop-nvim
    kommentary
    nvim-ts-context-commentstring
    nvim-surround
    vim-repeat
    vim-unimpaired
    vim-matchup
    guess-indent-nvim
    vim-dispatch

    # Treesitter-adjacent / filetypes
    render-markdown-nvim
    vimwiki
    yuck-vim

    # Copilot
    copilot-lua
    copilot-vim

    # SQL
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion

    # Shared libs
    plenary-nvim
  ];

  treesitter-plugins = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;

  allPlugins =
    nix-nvim-plugins ++ custom-sourced-nvim-plugins ++ pkgs.lib.singleton treesitter-plugins;
in
allPlugins
