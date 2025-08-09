local snacks = require("snacks")
local ignored_filetypes = require("utils").ignored_filetypes

snacks.setup({
	bigfile = { enabled = true },
	bufdelete = { enabled = true },
	quickfile = { enabled = true },
	input = { enabled = true },
	indent = {
		enabled = true,
		scope = { enabled = false },
	},
	scroll = {
		enabled = false,
		animate_repeat = {
			delay = 100, -- delay in ms before using the repeat animation
			duration = { step = 4, total = 100 },
			easing = "linear",
		},
		filter = function(buf)
			return vim.g.snacks_scroll ~= false
				and vim.b[buf].snacks_scroll ~= false
				and vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype) == false
		end,
	},
})

require("which-key").add({
	{ "<leader>bd", snacks.bufdelete.delete, desc = "Delete this buffer" },
	{ "<leader>ba", snacks.bufdelete.all, desc = "Delete all buffers" },
	{ "<leader>bo", snacks.bufdelete.other, desc = "Delete other buffers" },
})

local autocmd = vim.api.nvim_create_autocmd
