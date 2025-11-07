local lspconfig = require("lspconfig")
local util = lspconfig.util

-- Function to find git root
local function get_git_root()
  local git_root =
    vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })[1]
  if git_root and git_root ~= "" and not git_root:match("^fatal") then
    return git_root
  end
  return nil
end

vim.lsp.config("terragruntls", {
  cmd = { "terragrunt-ls" },
  filetypes = { "hcl" },
  root_dir = lspconfig.util.root_pattern(".git", "."),
  settings = {},
})

vim.lsp.enable("terragruntls")

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
    root_dir = util.root_pattern(".git"),
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
    on_attach = function(client, bufnr)
      -- Disable specific diagnostics for line length
      vim.diagnostic.config({
        virtual_text = {
          source = "if_many",
          -- Filter out line-too-long errors
          format = function(diagnostic)
            if
              diagnostic.source == "actionlint"
              and diagnostic.message:match("line too long")
            then
              return nil
            end
            if
              diagnostic.message:match("line too long")
              or diagnostic.message:match("line length")
            then
              return nil
            end
            return diagnostic.message
          end,
        },
      }, bufnr)
    end,
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
  nil_ls = {
    cmd = { "nil" },
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
  terraformls = {
    init_options = {
      experimentalFeatures = {
        prefillRequiredFields = true,
      },
    },
  },

  terragruntls = {},
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
  vtsls = {},
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
          },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 20000,
          requestTimeout = 5000,
        },
        semantic = { enable = false },
      },
    },
  },
}
