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
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentFormattingRangeProvider = false
    end,
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
    root_dir = require("lspconfig").util.root_pattern(
      "mix.exs",
      "rebar.config"
    ),
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        fetchDeps = true,
        enableTestLenses = true,
        suggestSpecs = true,
      },
    },
  },
  -- REVIEW tailwindcss = {},
  hls = {},
  dockerls = {},
  bashls = {},
  terraformls = {},
  gopls = {},
  vtsls = {},
  eslint = {},
  jsonls = { cmd = { "vscode-json-languageserver", "--stdio" } },
  graphql = {},
  lua_ls = {
    cmd = { "lua-language-server" },
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentFormattingRangeProvider = false
    end,
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
