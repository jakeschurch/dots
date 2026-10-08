local lint = require("lint")

-- Only linters that no configured LSP already provides. eslint, shellcheck and
-- terraform_validate are covered by eslint-ls, bashls and terraformls; pyright
-- covers what mypy was doing.
lint.linters_by_ft = {
  python = { "ruff" },
  nix = { "statix", "deadnix" },
  yaml = { "yamllint" },
  -- tflint catches provider and naming problems; trivy is the IaC security
  -- scan that absorbed tfsec when Aqua archived it.
  terraform = { "tflint", "trivy" },
  ["yaml.github"] = { "actionlint" },
  go = { "golangcilint" },
  dockerfile = { "hadolint" },
  elixir = { "credo" },
  css = { "stylelint" },
  scss = { "stylelint" },
  sql = { "sqlfluff" },
  gitcommit = { "gitlint" },
  ["yaml.ansible"] = { "ansible_lint" },
  markdown = { "codespell" },
  vimwiki = { "codespell" },
  text = { "codespell" },
}

-- Keep the trailing "-": the linter feeds the buffer on stdin, and without it
-- sqlfluff lints the whole cwd and every file's violations land on this buffer.
lint.linters.sqlfluff.args = {
  "lint",
  "--format=json",
  "--dialect=postgres",
  "-",
}

-- Drop yamllint's line-length rule unless the project ships its own config.
-- -d replaces config discovery, so a project file is passed through `extends`.
lint.linters.yamllint.args = {
  "-d",
  function()
    local own =
      vim.fs.find({ ".yamllint", ".yamllint.yaml", ".yamllint.yml" }, {
        upward = true,
        path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      })[1]
    if own then
      return ('{extends: "%s"}'):format(own)
    end
    return "{extends: default, rules: {line-length: disable}}"
  end,
  "--format",
  "parsable",
  "-",
}

lint.linters.codespell.args = {
  "--builtin",
  "clear,rare,code,usage",
  "-",
}

local function try_lint()
  if vim.bo.buftype ~= "" then
    return
  end
  if vim.bo.filetype == "elixir" then
    -- Credo is a project dependency, so nvim-lint correctly invokes it as
    -- `mix credo`. Only run it from a Mix project root; standalone .ex files
    -- should not emit a missing-project error.
    local mix_root = vim.fs.root(0, { "mix.exs" })
    if mix_root then
      lint.try_lint("credo", { cwd = mix_root })
    end
    return
  end
  lint.try_lint()
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("lint", { clear = true }),
  callback = try_lint,
  desc = "Run linters that no LSP covers",
})

try_lint()
