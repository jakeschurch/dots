local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local codecompanion_group = augroup("CodeCompanionAutoSave", { clear = true })

local function save_codecompanion_buffer(bufnr)
	local save_dir = vim.fn.expand("~/.cache/nvim/codecompanion/")
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local bufname = vim.api.nvim_buf_get_name(bufnr)

	-- Extract the unique ID from the buffer name
	local id = bufname:match("%[CodeCompanion%] (%d+)")
	local date = os.date("%Y-%m-%d")
	local save_path

	if id then
		-- Use date plus ID to ensure uniqueness
		save_path = save_dir .. date .. "_codecompanion_" .. id .. ".md"
	else
		-- Fallback with timestamp to ensure uniqueness if no ID
		save_path = save_dir .. date .. "_codecompanion_" .. os.date("%H%M%S") .. ".md"
	end

	-- Write buffer content to file
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local file = io.open(save_path, "w")
	if file then
		file:write(table.concat(lines, "\n"))
		file:close()
	end
end

autocmd({ "InsertLeave", "TextChanged", "BufLeave", "FocusLost" }, {
	group = codecompanion_group,
	callback = function(args)
		local bufnr = args.buf
		local bufname = vim.api.nvim_buf_get_name(bufnr)

		if bufname:match("%[CodeCompanion%]") then
			save_codecompanion_buffer(bufnr)
		end
	end,
})
