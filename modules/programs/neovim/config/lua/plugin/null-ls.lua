local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    -- Generic
    require("none-ls.formatting.trim_newlines"),
    require("none-ls.formatting.trim_whitespace"),

    -- Python
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.pylint.with({
      extra_args = {
        "--rcfile",
        "~/.pylintrc",
        "--disable=missing-module-docstring",
        "--disable=missing-class-docstring",
        "--disable=missing-function-docstring",
      },
      diagnostics_postprocess = function(diagnostic)
        diagnostic.code = diagnostic.message_id
      end,
    }),

    require("none-ls.diagnostics.flake8").with({
      extra_args = {
        "--max-line-length=100",
        "--ignore=E501,W504,E303,F405,E402,W403,W503",
      },
    }),
    null_ls.builtins.diagnostics.mypy,

    -- Shell
    null_ls.builtins.formatting.shellharden.with({
      filetypes = { "sh", "bash" },
    }),

    -- JavaScript/TypeScript
    null_ls.builtins.formatting.prettier.with({
      extra_args = { "--write" },
      filetypes = { "html", "json", "yaml", "markdown" },
    }),

    require("none-ls.code_actions.eslint"),
    require("none-ls.diagnostics.eslint"),

    -- Lua
    null_ls.builtins.formatting.stylua.with({
      extra_args = {
        "--indent-type",
        "Spaces",
        "--indent-width",
        "2",
        "--column-width",
        "80",
      },
    }),

    -- Go
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.goimports_reviser,
    null_ls.builtins.formatting.golines,

    -- Spelling
    null_ls.builtins.completion.spell.with({
      filetypes = { "txt", "markdown", "vimwiki" },
    }),
    null_ls.builtins.diagnostics.codespell.with({
      args = { "--builtin", "clear,rare,code,usage,code", "-" },
    }),
    null_ls.builtins.hover.dictionary,
    null_ls.builtins.diagnostics.vale.with({
      args = { "--config", os.getenv("XDG_CONFIG_HOME") .. "/vale/vale.ini" },
    }),

    -- Nix
    null_ls.builtins.diagnostics.statix,
    null_ls.builtins.code_actions.statix,
    null_ls.builtins.diagnostics.deadnix,

    -- Git
    null_ls.builtins.diagnostics.gitlint,

    -- Terraform/hcl
    null_ls.builtins.formatting.terraform_fmt,
    null_ls.builtins.formatting.packer,
    null_ls.builtins.formatting.hclfmt,
    null_ls.builtins.diagnostics.terraform_validate,
    null_ls.builtins.diagnostics.tfsec,

    null_ls.builtins.diagnostics.ansiblelint,

    -- Docs
    null_ls.builtins.diagnostics.yamllint,
    null_ls.builtins.diagnostics.actionlint,

    null_ls.builtins.formatting.tidy,

    -- sql
    null_ls.builtins.diagnostics.sqlfluff.with({
      extra_args = { "--dialect", "postgres" },
    }),
    null_ls.builtins.formatting.sqlfluff.with({
      extra_args = { "--dialect", "postgres" },
    }),

    -- elixir
    null_ls.builtins.diagnostics.credo,

    -- html, css
    null_ls.builtins.diagnostics.stylelint,
    null_ls.builtins.diagnostics.tidy,

    -- markdown
    null_ls.builtins.formatting.mdformat.with({
      extra_args = {
        "--wrap",
        "80",
        "--extensions",
        "mdformat-admon",
        "mdformat-gfm",
        "mdformat-gfm-alerts",
        "mdformat-frontmatter",
        "mdformat-tables",
        "mdformat-beautysh",
        "mdformat-footnote",
        "--code-formatters",
        "sh",
      },
    }),
    null_ls.builtins.diagnostics.trail_space,

    -- docker
    null_ls.builtins.diagnostics.hadolint,

    -- vim
    null_ls.builtins.diagnostics.vint,
  },
  debug = false,
})
