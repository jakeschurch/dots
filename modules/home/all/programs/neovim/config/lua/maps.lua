-- window movements
vim.keymap.set("n", "<C-q>", "<C-w>q")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- better command defaults
vim.keymap.set("n", "!", ":!")

-- save whole line in buffer
vim.keymap.set("n", "Y", "^y$")

-- quick save
vim.keymap.set("n", "W", ":wa!<cr>", { noremap = true, silent = true })

-- change pwd to file dir
vim.keymap.set("n", "<leader>hf", ":lcd %:p:h<cr>", { noremap = true, silent = true })

vim.keymap.set("n", "J", "mzJ`z") -- keep cursor in original place while joining lines
vim.keymap.set("n", "<C-d>", "<C-d>zz") -- pgdn
vim.keymap.set("n", "<C-u>", "<C-u>zz") -- pgup

-- centered cursor on search and navigation
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "j", "jzz")
vim.keymap.set("n", "k", "kzz")
vim.keymap.set("n", "{", "{zz")
vim.keymap.set("n", "}", "}zz")

-- Map <Esc> to itself with feedkeys for immediate recognition
vim.keymap.set("i", "<Esc>", function()
	return vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
end, { expr = true })

function ToggleQuickFix()
	local qf_exists = false
	-- Check if the quickfix window is open
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			qf_exists = true
			break
		end
	end

	if qf_exists then
		vim.cmd("cclose")
	else
		vim.cmd("copen")
	end
end

-- Optionally, map this function to a keybinding, e.g., <leader>q
vim.keymap.set("n", "<leader>q", function()
	ToggleQuickFix()
end, { noremap = true, silent = true })

vim.cmd([[
cnoremap %s/ %s/\v

cnoreabbrev <expr> c (getcmdtype() == ':' && getcmdline() == 'c') ? 'G commit -m' : 'c'
cnoreabbrev <expr> a (getcmdtype() == ':' && getcmdline() == 'a') ? 'G add %' : 'a'
]])

function Cycle(direction)
	local line = vim.api.nvim_get_current_line()
	local original_cursor = vim.api.nvim_win_get_cursor(0) -- Save original position
	local col = original_cursor[2]

	local booleans = {
		["true"] = "false",
		["false"] = "true",
		["on"] = "off",
		["off"] = "on",
		["yes"] = "no",
		["no"] = "yes",
	}

	for bool, replacement in pairs(booleans) do
		local start_pos, end_pos = string.find(line, "%f[%a]" .. bool .. "%f[%A]") -- Match whole word

		if start_pos then
			vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], start_pos - 1 })

			vim.cmd("normal! ciw" .. replacement)

			vim.api.nvim_win_set_cursor(0, { original_cursor[1], col })
			return
		end
	end

	local direction_mapping = {
		["down"] = "<C-X>",
		["up"] = "<C-A>",
	}

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(direction_mapping[direction], true, false, true), "n", true)

	vim.api.nvim_win_set_cursor(0, original_cursor)
end

vim.keymap.set("n", "<C-X>", function()
	Cycle("down")
end, { noremap = true, silent = true })

vim.keymap.set("n", "<C-A>", function()
	Cycle("up")
end, { noremap = true, silent = true })

function ToggleLocationList()
	local loclist_exists = false
	-- Check if the location list is open for the current window
	for _, win in ipairs(vim.fn.getwininfo()) do
		if win.loclist == 1 and win.winid == vim.api.nvim_get_current_win() then
			loclist_exists = true
			break
		end
	end

	if loclist_exists then
		vim.cmd("lclose")
	else
		vim.cmd("lopen")
	end
end

vim.keymap.set("n", "<leader>l", function()
	ToggleLocationList()
end, { noremap = true, silent = true })

-- Smart paste in insert mode (adjusts indentation after pasting)
function SmartPasteInsert()
	-- Turn off 'paste' mode to respect indentation settings
	vim.opt.paste = false
	-- Use normal mode commands to re-indent the last pasted block
	vim.cmd("normal! `[v`]=")
end

-- Smart paste in normal mode (adjusts indentation after pasting)
function SmartPasteNormal()
	-- Turn off 'paste' mode to respect indentation settings
	vim.opt.paste = false
	-- Use visual selection to re-indent the pasted block
	vim.cmd("normal! `[v`]=")
end

-- -- Key mappings for smart pasting
-- -- In insert mode, use <C-r> to paste with automatic indentation
-- vim.api.nvim_set_keymap(
--   "i",
--   "<C-r>",
--   "<C-o>:lua SmartPasteInsert()<CR>",
--   { noremap = true, silent = true }
-- )

-- In normal mode, use p to paste with automatic indentation
-- vim.api.nvim_set_keymap(
--   "n",
--   "p",
--   "p:lua SmartPasteNormal()<CR>",
--   { noremap = true, silent = true }
-- )
--
-- vim.api.nvim_set_keymap(
--   "n",
--   "P",
--   "P:lua SmartPasteNormal()<CR>",
--   { noremap = true, silent = true }
-- )
