local lint = require("lint")

-- Only linters that no configured LSP already provides. eslint, shellcheck and
-- terraform_validate are covered by eslint-ls, bashls and terraformls; pyright
-- covers what mypy was doing.
lint.linters_by_ft = {
  python = { "pylint" },
  nix = { "statix", "deadnix" },
  yaml = { "yamllint" },
  terraform = { "tfsec" },
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

lint.linters.pylint.args = {
  "--rcfile",
  vim.fs.normalize("~/.pylintrc"),
  "--disable=missing-module-docstring",
  "--disable=missing-class-docstring",
  "--disable=missing-function-docstring",
  "-f",
  "json",
  "--from-stdin",
  function()
    return vim.api.nvim_buf_get_name(0)
  end,
}

lint.linters.sqlfluff.args = {
  "lint",
  "--format=json",
  "--dialect=postgres",
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
  lint.try_lint()
end

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("lint", { clear = true }),
  callback = try_lint,
  desc = "Run linters that no LSP covers",
})

try_lint()
