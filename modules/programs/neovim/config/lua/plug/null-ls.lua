local status_ok, null_ls = pcall(require, "null-ls")

local lsp_status_ok, lsp = pcall(require, "lsp")

null_ls.setup({
	sources = {
		-- Generic
		-- null_ls.builtins.code_actions.prose_lint,
		--
		--	-- Python
		null_ls.builtins.formatting.black,
		null_ls.builtins.formatting.isort,
		-- REVIEW
		-- null_ls.builtins.diagnostics.pylint.with({
		-- 	extra_args = {
		-- 		"--rcfile",
		-- 		"~/.pylintrc",
		-- 		"--disable=missing-module-docstring",
		-- 		"--disable=missing-class-docstring",
		-- 		"--disable=missing-function-docstring",
		-- 	},
		-- 	diagnostics_postprocess = function(diagnostic)
		-- 		diagnostic.code = diagnostic.message_id
		-- 	end,
		-- }),

		require("none-ls.diagnostics.flake8").with({
			extra_args = { "--max-line-length=100", "--ignore=E501,W504,E303,F405,E402,W403,W503" },
		}),
		null_ls.builtins.diagnostics.mypy,

		-- Shell
		null_ls.builtins.formatting.shfmt,
		null_ls.builtins.formatting.shellharden,
		require("none-ls-shellcheck.diagnostics"),
		require("none-ls-shellcheck.code_actions"),

		-- JavaScript/TypeScript
		null_ls.builtins.formatting.prettier.with({
			extra_args = { "--write" },
			filetypes = { "html", "json", "yaml", "markdown" },
		}),

		require("none-ls.code_actions.eslint"),
		require("none-ls.diagnostics.eslint"),
		null_ls.builtins.diagnostics.tsc,

		-- Lua
		null_ls.builtins.formatting.stylua,

		null_ls.builtins.formatting.prettier_d_slim,

		-- Spelling
		null_ls.builtins.completion.spell.with({
			filetypes = { "txt", "markdown", "vimwiki" },
		}),
		null_ls.builtins.diagnostics.codespell.with({
			args = { "--builtin", "clear,rare,code,usage,code", "-" },
		}),
		null_ls.builtins.hover.dictionary,
		null_ls.builtins.diagnostics.vale,

		-- Nix
		null_ls.builtins.diagnostics.statix,
		null_ls.builtins.code_actions.statix,
		null_ls.builtins.formatting.alejandra,
		null_ls.builtins.diagnostics.deadnix,

		-- haskell
		null_ls.builtins.formatting.brittany,
		null_ls.builtins.formatting.cabal_fmt,

		-- Git
		null_ls.builtins.diagnostics.gitlint,

		-- Terraform/hcl
		null_ls.builtins.formatting.terraform_fmt,
		null_ls.builtins.formatting.packer,

		null_ls.builtins.diagnostics.ansiblelint,

		-- Docs
		-- null_ls.builtins.diagnostics.yamllint,

		-- null_ls.builtins.diagnostics.jsonlint,
		-- null_ls.builtins.formatting.tidy,

		-- REVIEW
		-- null_ls.builtins.diagnostics.alex,

		-- sql
		null_ls.builtins.diagnostics.sqlfluff.with({
			extra_args = { "--dialect", "postgres" },
		}),
		null_ls.builtins.formatting.sqlfluff.with({
			args = { "format", "--disable-progress-bar", "-" },
			extra_args = { "--dialect", "postgres" },
		}),

		-- elixir
		null_ls.builtins.diagnostics.credo,
		null_ls.builtins.formatting.mix,

		-- html, css
		-- null_ls.builtins.diagnostics.stylelint,
		-- null_ls.builtins.diagnostics.tidy,

		-- vim
		--null_ls.builtins.diagnostics.vint,
	},
	debug = true,
	on_attach = lsp.common_on_attach,
})
