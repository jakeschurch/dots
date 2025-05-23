local fzf_lua = require("fzf-lua")
local which_key = require("which-key")

local config = {
	"ivy",
	"fzf-native",
	live_grep = {
		rg_glob = true,
		glob_flag = "--iglob", -- for case sensitive globs use '--glob'
		glob_separator = "%s%-%-", -- query separator pattern (lua): ' --'
		hidden = true,
	},
	fzf_colors = true,
	keymap = {
		builtin = {
			["<c-d>"] = "preview-down",
			["<c-u>"] = "preview-up",
		},
		fzf = {
			true,
			["ctrl-q"] = "select-all+accept", -- Send all items to qf list
		},
		["ctrl-j"] = nil,
		["ctrl-k"] = nil,

		["ctrl-c"] = "abort",
		["esc"] = "abort",

		["ctrl-n"] = "preview-page-down",
		["ctrl-p"] = "preview-page-up",
	},
	files = {
		prompt = nil,
	},
	globals = {
		winopts = {
			preview = {
				default = "bat_native",
				border = "noborder",
				scrollbar = false,
				title = nil,
			},
		},
	},
}

fzf_lua.setup(config)

local function recent_git_branches()
	-- Use git reflog to get unique, most recently checked-out branches
	local handle = io.popen("git reflog | grep 'checkout:' | awk '{print $NF}' | awk '!seen[$0]++'")
	if not handle then
		return
	end
	local result = handle:read("*a")
	handle:close()

	local branches = {}
	for branch in result:gmatch("[^\r\n]+") do
		table.insert(branches, branch)
	end

	fzf_lua.fzf_exec(branches, {
		prompt = "Recent Branches> ",
		actions = {
			["default"] = function(selected)
				vim.cmd("Git checkout " .. selected[1])
			end,
		},
	})
end

which_key.add({
	{
		"<leader>bb",
		fzf_lua.buffers,
		desc = "Show Buffers",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fc",
		fzf_lua.command_history,
		desc = "Command History",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fg",
		recent_git_branches,
		desc = "Git Branches",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fh",
		fzf_lua.help_tags,
		desc = "Help Tags",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fk",
		fzf_lua.keymaps,
		desc = "Keymaps",
		nowait = true,
		remap = false,
	},
	{
		"<leader>fm",
		fzf_lua.manpages,
		desc = "Man Pages",
		nowait = true,
		remap = false,
	},
	{
		"<leader>ja",
		fzf_lua.resume,
		desc = "Resume fzf lua search",
		nowait = true,
		remap = false,
	},
	{
		"<leader>jj",
		fzf_lua.live_grep_native,
		desc = "Grep",
		nowait = true,
		remap = false,
	},
	--- git mappings
	{
		"<leader>jk",
		fzf_lua.git_files,
		desc = "Git Files",
		nowait = true,
		remap = false,
	},
	{
		"<leader>gb",
		recent_git_branches,
		desc = "Checkout Branch",
		nowait = true,
		remap = false,
	},
	{
		"<leader>gc",
		fzf_lua.git_commits,
		desc = "Checkout Commit",
		nowait = true,
		remap = false,
	},
	{
		"<leader>go",
		fzf_lua.git_status,
		desc = "Open Changed File",
		nowait = true,
		remap = false,
	},
})
