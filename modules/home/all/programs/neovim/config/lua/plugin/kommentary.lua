local status_ok, komment_config = pcall(require, "kommentary.config")
if not status_ok then
	return
end

require("ts_context_commentstring").setup({
	enable_autocmd = false,
})

local lang_configs = {
	default = {
		prefer_single_line_comments = true,
		ignore_whitespace = false,
	},
	nix = {
		single_line_comment_string = "#",
		prefer_single_line_comments = true,
	},
	javascript = {
		prefer_single_line_comments = false, -- due to jsdoc
	},
}

local function setup_nvim_commentstring()
	require("ts_context_commentstring").update_commentstring()
end

for lang, config in pairs(lang_configs) do
	config.hook_function = setup_nvim_commentstring
	config.single_line_comment_string = "auto"
	config.multi_line_comment_string = "auto"

	komment_config.configure_language(lang, config)
end

local remap = vim.api.nvim_set_keymap
remap("n", "<leader>c", "<Plug>kommentary_line_default", {})
remap("v", "<leader>c", "<Plug>kommentary_visual_default", {})
