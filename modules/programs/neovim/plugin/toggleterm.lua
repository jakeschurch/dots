local keymap = require("utils").keymap

---@diagnostic disable-next-line: unused-function
function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	keymap("t", "<esc><esc>", [[<C-\><C-n>]], opts)
	keymap("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

require("toggleterm").setup({
	close_on_exit = false,
	direction = "float",
	open_mapping = [[<c-\>]],
	persist_size = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = "3",
	shell = vim.o.shell,
	insert_mappings = true,
	hide_numbers = true,
	size = 80,

	start_in_insert = true,
	float_opts = {
		border = "single",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})
