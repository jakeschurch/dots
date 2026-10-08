return {
  -- vale-ls exits 1 when there is no .vale.ini, so only attach where a project
  -- actually configures vale. Run `vale sync` after writing one.
  vale_ls = {
    root_dir = function(bufnr, on_dir)
      local ini = vim.fs.find(".vale.ini", {
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
        upward = true,
      })[1]
      if ini then
        on_dir(vim.fs.dirname(ini))
      end
    end,
  },
  regal = {},
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
    -- lspconfig's list plus the Phoenix template types.
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
  },
  nixd = {},
  taplo = {},
  pyright = {
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
  expert = {},
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
  jsonls = {},
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
