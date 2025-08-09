local lsp = {}
local lsp_config = require("lspconfig")

local lsp_status = require("lsp-status")
lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.diagnostic.config({
	virtual_text = false, -- Enable virtual text for diagnostics
	underline = true, -- Underline the text with diagnostics
	update_in_insert = false, -- Don't update diagnostics in insert mode
	severity_sort = true, -- Sort diagnostics by severity
	float = {
		focusable = true,
		style = "minimal",
		border = "rounded", -- Rounded border for floating windows
	},
	signs = {
		severity = {
			[vim.diagnostic.severity.ERROR] = { text = " " },
			[vim.diagnostic.severity.WARN] = { text = " " },
			[vim.diagnostic.severity.INFO] = { text = " " },
			[vim.diagnostic.severity.HINT] = { text = " " },
		},
	},
})

-- make a new command for formatting the buffer
vim.api.nvim_create_user_command("Format", function()
	vim.lsp.buf.format()
end, {})

local wk = require("which-key")
wk.add({
	{ "<leader>K", "Hover doc" },
	{ "<leader>gd", "Go to definition" },
	{ "<leader>gi", "Go to implementation" },
})

local function diagnostic_jump_next(severity)
	if #require("lspsaga.diagnostic"):get_diagnostic({ buffer = true }) == 0 then
		return
	end
	if severity then
		require("lspsaga.diagnostic"):diagnostic_jump_next({ severity = severity })
	else
		vim.cmd("Lspsaga diagnostic_jump_next")
	end
	require("lspsaga.diagnostic"):show_diagnostics({ cursor = true })
end

local function diagnostic_jump_prev(severity)
	if #require("lspsaga.diagnostic"):get_diagnostic({ buffer = true }) == 0 then
		return
	end
	if severity then
		require("lspsaga.diagnostic"):diagnostic_jump_prev({ severity = severity })
	else
		vim.cmd("Lspsaga diagnostic_jump_prev")
	end
	require("lspsaga.diagnostic"):show_diagnostics({ cursor = true })
end

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local opts = { buffer = bufnr, noremap = true, silent = true }

		vim.keymap.set("n", "<leader>l", function()
			local enabled = vim.lsp.inlay_hint.is_enabled()
			vim.lsp.inlay_hint.enable(not enabled)
			print("Inlay hints " .. (enabled and "disabled" or "enabled"))
		end, { desc = "Toggle Inlay Hints" })

		vim.keymap.set("i", "<C-k>", vim.lsp.buf.hover, opts)
		vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
		vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)

		vim.keymap.set("n", "<leader>f", function()
			vim.lsp.buf.format()
		end, { buffer = bufnr })

		vim.keymap.set("n", "gy", function()
			vim.cmd("Lspsaga goto_type_definition")
		end, opts)

		vim.keymap.set("n", "gd", function()
			vim.cmd("Lspsaga goto_definition")
		end, opts)

		vim.keymap.set("n", "gr", function()
			vim.cmd("Lspsaga finder")
		end, opts)

		vim.keymap.set("n", "gp", function()
			vim.cmd("Lspsaga peek_definition")
		end, opts)
		vim.keymap.set("n", "<leader>rn", function()
			vim.cmd("Lspsaga rename")
		end, opts)

		-- Diagnostic navigation
		vim.keymap.set("n", "[d", function()
			diagnostic_jump_prev(vim.diagnostic.severity.ERROR)
		end, opts)

		vim.keymap.set("n", "]d", function()
			diagnostic_jump_next(vim.diagnostic.severity.ERROR)
		end, opts)

		vim.keymap.set("n", "[g", function()
			diagnostic_jump_prev()
		end, opts)

		vim.keymap.set("n", "]g", function()
			diagnostic_jump_next()
		end, opts)

		-- Call hierarchy
		vim.keymap.set("n", "<Leader>hc", function()
			vim.cmd("Lspsaga incoming_calls")
		end, opts)
		vim.keymap.set("n", "<Leader>ho", function()
			vim.cmd("Lspsaga outgoing_calls")
		end, opts)

		-- Code actions
		vim.keymap.set({ "n", "v" }, "<leader>qf", function()
			vim.cmd("Lspsaga code_action")
		end, opts)
	end,
})

for server, config in pairs(require("plugin.lsp_servers")) do
	config.capabilities = vim.tbl_deep_extend(
		"force",
		config.capabilities or {},
		-- File watching is disabled by default for neovim.
		-- See: https://github.com/neovim/neovim/pull/22405
		{ workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
		require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
	)

	config["root_dir"] = config["root_dir"]
		or function(fname)
			local util = require("lspconfig.util")
			return util.root_pattern(".git")(fname) or nil
		end

	lsp_config[server].setup(config)
end

return lsp
