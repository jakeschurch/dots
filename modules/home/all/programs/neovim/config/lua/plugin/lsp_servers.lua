vim.filetype.add({
  pattern = {
    [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
    ["helmfile%.ya?ml"] = "yaml.helm-values",
    [".*/templates/.*%.ya?ml"] = "yaml.helm-values",
    ["Chart%.ya?ml"] = "yaml",
    ["docker%-compose.*%.ya?ml"] = "yaml.docker-compose",
    ["docker%-compose.*%.yaml"] = "yaml.docker-compose",
    [".*%.gitlab%-ci.*%.ya?ml"] = "yaml.gitlab",
    [".*/%.gitlab%-ci/.*%.ya?ml"] = "yaml.gitlab",
  },
})

local default_publish_diagnostics =
  vim.lsp.handlers["textDocument/publishDiagnostics"]
local handlers = {
  ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
    result.diagnostics = vim.tbl_filter(function(d)
      return not (
        d.message:match("line too long") or d.message:match("line length")
      )
    end, result.diagnostics)
    default_publish_diagnostics(_, result, ctx, config)
  end,
}

return {
  vale_ls = {},
  regal = {},
  regols = {
    cmd = { "regols" },
    filetypes = { "rego" },
  },
  digestif = {}, -- latex
  yamlls = {
    settings = {
      yaml = {
        format = {
          enable = true,
          printWidth = 0,
        },
        validate = true,
        hover = true,
        completion = true,
        customTags = {},
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
      },
      redhat = {
        telemetry = {
          enabled = false,
        },
      },
    },
    handlers = handlers,
  },
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
  nixd = {},
  pyright = {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    settings = {
      python = {
        analysis = {
          typeCheckingMode = "basic",
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          useLibraryCodeForTypes = false,
        },
      },
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        inlayHints = {
          typeHints = true,
          parameterHints = true,
          chainingHints = true,
          lifetimeElisionHints = {
            enable = true,
            useParameterNames = true,
          },
        },
      },
    },
  },
  expert = {
    cmd = { "expert", "--stdio" },
    filetypes = { "elixir", "eelixir", "heex" },
    root_markers = { "mix.exs", ".git" },
  },
  hls = {},
  dockerls = {},
  bashls = {},
  terraformls = {
    init_options = {
      experimentalFeatures = {
        prefillRequiredFields = true,
      },
    },
  },

  terragruntls = {
    cmd = { "terragrunt-ls" },
    filetypes = { "hcl" },
    root_markers = { ".git", "terragrunt.hcl" },
  },
  gopls = {
    settings = {
      gopls = {
        hints = {
          rangeVariableTypes = true,
          parameterNames = true,
          constantValues = true,
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          functionTypeParameters = true,
        },
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
  vtsls = {
    settings = {
      typescript = {
        inlayHints = {
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
        updateImportsOnFileMove = { enabled = "always" },
      },
      javascript = {
        inlayHints = {
          parameterNames = { enabled = "literals" },
          parameterTypes = { enabled = true },
          variableTypes = { enabled = true },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = true },
          enumMemberValues = { enabled = true },
        },
        updateImportsOnFileMove = { enabled = "always" },
      },
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
      },
    },
  },
  eslint = {},
  jsonls = { cmd = { "vscode-json-languageserver", "--stdio" } },
  lua_ls = {
    settings = {
      Lua = {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = "LuaJIT",
        },
        hint = {
          enable = true,
          arrayIndex = "Disable",
          setType = true,
        },
        diagnostics = {
          globals = { "vim" },
        },
        format = {
          enable = true,
          defaultConfig = {
            indent_style = "space",
            indent_size = "2",
            column_width = "80",
          },
        },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
          maxPreload = 1000,
          requestTimeout = 5000,
        },
        semantic = { enable = false },
      },
    },
  },
}
