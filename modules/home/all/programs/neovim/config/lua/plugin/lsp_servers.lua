-- Helper to create root_dir functions compatible with vim.lsp.config
local function root_pattern(...)
  local patterns = { ... }
  return function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, patterns)
    if root then
      on_dir(root)
    end
  end
end

vim.filetype.add({
  pattern = {
    [".*/%.github[%w/]+workflows[%w/]+.*%.ya?ml"] = "yaml.github",
  },
})

return {
  vale_ls = {},
  regal = {},
  regols = {
    cmd = { "regols" },
    filetypes = { "rego" },
    root_dir = root_pattern(".git"),
  },
  digestif = {}, -- latex
  yamlls = {
    settings = {
      yaml = {
        format = {
          enable = true,
          printWidth = 0, -- Disable line length formatting
        },
        validate = true,
        hover = true,
        completion = true,
        -- Disable line length warnings
        customTags = {},
        schemaStore = {
          enable = true,
          url = "https://www.schemastore.org/api/json/catalog.json",
        },
      },
      -- Disable actionlint line length warnings
      redhat = {
        telemetry = {
          enabled = false,
        },
      },
    },
    handlers = {
      ["textDocument/publishDiagnostics"] = function(_, result, ctx, config)
        result.diagnostics = vim.tbl_filter(function(d)
          return not (
            d.message:match("line too long") or d.message:match("line length")
          )
        end, result.diagnostics)
        vim.lsp.diagnostic.on_publish_diagnostics(_, result, ctx, config)
      end,
    },
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
  elixirls = {
    cmd = { "elixir-ls" },
    settings = {
      elixirLS = {
        dialyzerEnabled = true,
        enableTestLenses = true,
        suggestSpecs = true,
        signatureAfterComplete = true,
        mcpEnabled = false,
      },
    },
  },
  expert = {
    cmd = { "expert", "--stdio" },
    filetypes = { "elixir", "eelixir", "heex" },
    root_dir = root_pattern("mix.exs", ".git"),
  },
  -- REVIEW tailwindcss = {},
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
    root_dir = root_pattern(".git", "terragrunt.hcl"),
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
    on_init = function(client)
      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath("config")
          and (
            vim.loop.fs_stat(path .. "/.luarc.json")
            or vim.loop.fs_stat(path .. "/.luarc.jsonc")
          )
        then
          return
        end
      end
    end,
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
