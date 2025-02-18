pkgs: let
  # avante-nvim' = pkgs.vimPlugins.avante-nvim.overrideAttrs (_: rec {
  #   version = "0.0.14";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "yetone";
  #     repo = "avante.nvim";
  #     rev = "v${version}";
  #     sha256 = "sha256-REFF+4U0AjNwiK1ecbDPwF7C1jKRzITV29aolx+HI24=";
  #   };
  # });

  custom-sourced-nvim-plugins = let
    pluginGit = {
      rev,
      owner,
      repo,
      sha256,
      ...
    }:
      pkgs.vimUtils.buildVimPlugin {
        pname = "${pkgs.lib.strings.sanitizeDerivationName repo}";
        version = rev;
        src = pkgs.fetchFromGitHub {
          inherit owner repo rev sha256;
        };
      };

    readJsonFile = with builtins; file: fromJSON (readFile file);
    vimPluginsToFetch = readJsonFile ./versions.json;
  in
    map pluginGit vimPluginsToFetch;

  nix-nvim-plugins = with pkgs.vimPlugins;
    [
      nvim-dap-python
      nvim-lspconfig
      copilot-cmp
      copilot-lua
      nvim-autopairs
      vimwiki
      vim-git
      vim-fugitive
      vim-dispatch
      oil-nvim
      cmp_luasnip
      nvim-dap-ui
      cmp-treesitter

      nvim-code-action-menu

      vim-unimpaired

      vim-repeat

      nvim-dap-virtual-text

      gitlinker-nvim

      nvim-dap-ui

      cmp-treesitter

      friendly-snippets

      octo-nvim

      hop-nvim

      lspkind-nvim

      none-ls-nvim

      lspsaga-nvim

      playground

      nvim-treesitter-textobjects

      nvim-treesitter
      lsp_signature-nvim

      telescope-nvim
      telescope-fzf-native-nvim
      telescope-fzy-native-nvim
      telescope-live-grep-args-nvim

      telescope-ui-select-nvim

      telescope-dap-nvim

      nvim-nio

      lualine-nvim

      popup-nvim

      plenary-nvim

      lsp-status-nvim

      completion-nvim

      nvim-lspconfig

      nvim-dap

      indent-blankline-nvim

      cmp-rg

      impatient-nvim

      gitsigns-nvim

      nvim-surround

      nvim-web-devicons

      vim-emoji

      fzf-vim

      virtual-types-nvim

      nvim-cmp

      cmp-path

      cmp-nvim-lsp

      cmp-emoji

      cmp-cmdline

      cmp-buffer

      alpha-nvim

      which-key-nvim

      gruvbox-nvim

      yuck-vim

      kommentary

      toggleterm-nvim

      nvim-treesitter-textsubjects
      render-markdown-nvim
      luasnip
      nvim-ts-context-commentstring
      avante-nvim

      trouble-nvim
    ]
    ++ (with pkgs.unstable.vimPlugins; [
      plenary-nvim
      dressing-nvim
      nui-nvim
    ]);

  treesitter-plugins = pkgs.unstable.vimPlugins.nvim-treesitter.withPlugins (
    ts-plugins:
      with ts-plugins; [
        awk
        bash
        comment
        css
        desktop
        dhall
        diff
        dockerfile
        elixir
        embedded_template
        func
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
        go
        gomod
        graphql
        haskell
        hcl
        heex
        html
        javascript
        jq
        json
        latex
        lua
        luadoc
        make
        tree-sitter-hcl
        markdown
        markdown_inline
        mermaid
        ninja
        nix
        passwd
        promql
        python
        regex
        rust
        sql
        ssh_config
        sxhkdrc
        templ
        terraform
        toml
        tsx
        typescript
        vim
        vimdoc
        yaml
        yuck
        gotmpl
        helm
      ]
  );
in
  nix-nvim-plugins
  ++ custom-sourced-nvim-plugins
  ++ pkgs.lib.singleton treesitter-plugins
