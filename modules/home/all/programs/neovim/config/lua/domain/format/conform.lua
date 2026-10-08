local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    -- ruff replaces isort + black, and its linter half replaces flake8/pylint.
    python = { "ruff_organize_imports", "ruff_format" },
    -- shellharden is a safety rewriter (it adds quoting), not a formatter;
    -- it stays available through :ShellHarden.
    sh = { "shfmt" },
    bash = { "shfmt" },
    lua = { "stylua" },
    nix = { "nixfmt" },
    toml = { "taplo" },
    elixir = { "mix" },
    eelixir = { "mix" },
    heex = { "mix" },
    -- golines formats through gofumpt (see below), so split lines keep its rules.
    go = { "goimports-reviser", "golines" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    scss = { "prettier" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    -- injected runs last so fenced code blocks get their language's real
    -- formatter rather than whatever mdformat's own codeformatters did.
    markdown = { "mdformat", "injected" },
    vimwiki = { "mdformat", "injected" },
    terraform = { "terraform_fmt" },
    tf = { "terraform_fmt" },
    hcl = { "terragrunt_hclfmt" },
    sql = { "sqlfluff" },
  },

  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 3000,
  },

  formatters = {
    -- mdformat enables every installed extension and code formatter by
    -- default; naming them explicitly takes one flag per name and errors out.
    mdformat = {
      prepend_args = { "--wrap", "80" },
    },
    -- conform only runs sqlfluff under a .sqlfluff/pyproject root by default,
    -- and `fix` exits 1 whenever unfixable violations remain even though it
    -- still prints the fixed SQL. --dialect belongs to the `fix` subcommand, so
    -- it can't go through prepend_args (that lands before `fix`).
    sqlfluff = {
      args = { "fix", "--dialect", "postgres", "-" },
      require_cwd = false,
      exit_codes = { 0, 1 },
    },
    golines = {
      prepend_args = { "--base-formatter", "gofumpt" },
    },
    shfmt = {
      prepend_args = { "--indent", "2", "--case-indent", "--binary-next-line" },
    },
    injected = {
      options = { ignore_errors = true },
    },
  },
})

vim.api.nvim_create_user_command("Format", function(opts)
  local range = nil
  if opts.count ~= -1 then
    local end_line =
      vim.api.nvim_buf_get_lines(0, opts.line2 - 1, opts.line2, true)[1]
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, end_line:len() },
    }
  end
  conform.format({ async = true, range = range })
end, { range = true, desc = "Format buffer or range" })

vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({ async = true })
end, { desc = "Format" })

vim.api.nvim_create_user_command("ShellHarden", function()
  conform.format({ async = true, formatters = { "shellharden" } })
end, { desc = "Rewrite shell quoting with shellharden" })

vim.api.nvim_create_user_command("FormatInjected", function()
  conform.format({ async = true, formatters = { "injected" } })
end, { desc = "Format only embedded code blocks" })
