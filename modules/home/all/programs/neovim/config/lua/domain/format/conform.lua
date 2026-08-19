local conform = require("conform")

conform.setup({
  formatters_by_ft = {
    python = { "isort", "black" },
    sh = { "shellharden" },
    bash = { "shellharden" },
    lua = { "stylua" },
    nix = { "nixfmt" },
    go = { "goimports-reviser", "gofumpt", "golines" },
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
    -- Format fenced code blocks with their own language's formatter.
    ["markdown.mdx"] = { "mdformat", "injected" },
    ["_"] = { lsp_format = "fallback" },
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
    sqlfluff = {
      prepend_args = { "--dialect", "postgres" },
    },
    injected = {
      options = { ignore_errors = true },
    },
  },
})

vim.api.nvim_create_user_command("Format", function(opts)
  local range = nil
  if opts.count ~= -1 then
    range = {
      start = { opts.line1, 0 },
      ["end"] = { opts.line2, math.huge },
    }
  end
  conform.format({ async = true, range = range })
end, { range = true, desc = "Format buffer or range" })

vim.keymap.set({ "n", "v" }, "<leader>f", function()
  conform.format({ async = true })
end, { desc = "Format" })

vim.api.nvim_create_user_command("FormatInjected", function()
  conform.format({ async = true, formatters = { "injected" } })
end, { desc = "Format only embedded code blocks" })
