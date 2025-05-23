require("vectorcode").setup({
	async_opts = {
		run_on_register = false,
		query_cb = require("vectorcode.utils").make_lsp_document_symbol_cb(),
	},
	async_backend = "lsp",
	on_setup = {
		update = false, -- set to true to enable update when `setup` is called.
		lsp = false,
	},
})

local cacher = require("vectorcode.config").get_cacher_backend()

local ignored_filetypes = require("utils").ignored_filetypes

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()
		local filetype = vim.bo[bufnr].filetype
		local filepath = vim.api.nvim_buf_get_name(bufnr)

		-- Check if the filetype is in the ignored list
		if vim.tbl_contains(ignored_filetypes, filetype) then
			return
		end

		-- Check if the file is tracked by Git
		local is_git_tracked =
			vim.fn.system(string.format("git ls-files --error-unmatch %s 2>/dev/null", vim.fn.fnameescape(filepath)))
		if vim.v.shell_error ~= 0 then
			return
		end

		cacher.async_check("config", function()
			cacher.register_buffer(bufnr, {
				n_query = 5,
			})
		end, nil)
	end,
	desc = "Register buffer for VectorCode",
})
