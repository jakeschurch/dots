return {
  yamlls = {},
  helm_ls = {
    settings = {
      ["helm-ls"] = {
        yamlls = {
          path = "yaml-language-server",
        },
      },
    },
  },
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
    cmd = {
      "nil",
      "--stdio",
    },
    settings = {
      ["nil"] = {
        formatting = {
          command = { "nixfmt" },
        },
      },
    },
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
  bashls = {
    cmd = { "/etc/profiles/per-user/jake/bin/bash-language-server", "start" },
    filetypes = { "sh", "bash" },
  },
  terraformls = {},
  gopls = {
    settings = {
      gopls = {
        experimentalPostfixCompletions = true,
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
      },
    },
    init_options = {
      usePlaceholders = true,
    },
  },
  vtsls = {},
  eslint = {},
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
            ["/Applications/Hammerspoon.app/Contents/Resources/extensions/hs"] = true,
            [vim.fn.expand("~/.hammerspoon/Spoons")] = true,
          },
          maxPreload = 10000,
        },
      },
    },
  },
}
