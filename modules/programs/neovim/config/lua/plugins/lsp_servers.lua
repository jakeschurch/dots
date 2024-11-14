return {
  emmet_ls = {
    filetypes = {
      "astro",
      "css",
      "eruby",
      "html",
      "htmldjango",
      "javascriptreact",
      "less",
      "pug",
      "sass",
      "scss",
      "svelte",
      "typescriptreact",
      "vue",
      "heex",
      "leex",
    },
    cmd = { "emmet-ls", "--stdio" },
  },
  nil_ls = {
    cmd = { "nil" },
  },
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = false,
        },
      },
    },
  },
  rust_analyzer = {},
  elixirls = {
    cmd = { "elixir-ls" },
  },
  -- REVIEW tailwindcss = {},
  hls = {},
  dockerls = {},
  bashls = {},
  terraformls = {},
  gopls = {},
  ts_ls = {
    flags = {
      debounce_text_changes = 150, -- Reduce frequency of updates
    },
    init_options = {
      maxTsServerMemory = 4096, -- Limit TS server memory (in MB)
      disableAutomaticTypingAcquisition = true,
    },
    root_dir = function(fname)
      return require("lspconfig").util.root_pattern(
        "package.json",
        "tsconfig.json",
        ".git"
      )(fname)
    end,
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        completeFunctionCalls = true,
      },
    },
  },
  eslint = {
    cmd = { "eslint", "--stdin" },
  },
  jsonls = { cmd = { "vscode-json-languageserver", "--stdio" } },
  graphql = {},
  lua_ls = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          },
          maxPreload = 10000,
        },
      },
    },
  },
}
