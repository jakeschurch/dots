vim.g.codecompanion_auto_tool_mode = true

require("plugin.llm.codecompanion.lualine_integration"):init()

local tools = {
	-- ["lsp_files"] = require("plugin.llm.codecompanion.tools.lsp_files"),
	["checklist"] = require("plugin.llm.codecompanion.tools.checklist_dag"),
	["file"] = {
		opts = {
			provider = "fzf_lua", -- Other options include 'default', 'mini_pick', 'fzf_lua', snacks
			contains_code = true,
		},
	},
}

local groups = {
	["agent"] = {
		description = "Agentic Dev Workflow",
		system_prompt = "You are a developer with access to various tools.",
		tools = {
			"cmd_runner",
			"editor",
			"files",
			"code_editor",
			"mcp",
		},
	},
}

local prompts = {
	["refactor"] = require("plugin.llm.codecompanion.prompts.refactoring"),
	["rfc"] = require("plugin.llm.codecompanion.prompts.rfc"),
	["git_commit"] = require("plugin.llm.codecompanion.prompts.git_commit"),
	["default"] = {
		strategy = "chat",
		description = "The default prompt with nice context",
		opts = {
			short_name = "def",
			auto_submit = false,
			user_prompt = false,
			is_slash_cmd = true,
			ignore_system_prompt = false,
			contains_code = true,
		},
		-- references = {
		--   {
		--     type = "file",
		--     path = ".github/copilot-instructions.md",
		--   },
		-- },
		prompts = {
			{
				role = "user",
				content = [[#buffer]],
			},
		},
	},
	["dynamic"] = {
		strategy = "chat",
		description = "The default prompt with nice context",
		opts = {
			short_name = "dynamic",
			auto_submit = false,
			user_prompt = false,
			is_slash_cmd = true,
			ignore_system_prompt = false,
			contains_code = true,
			stop_context_insertion = true,
		},
		references = {},
		prompts = {
			{
				role = "user",
				opts = {
					contains_code = true,
				},
				content = function(context)
					local rules = require("plugin.llm.codecompanion.rules")
					local rule_files = rules.init(context.filename, {
						root_markers = { ".git" },
						rules_dir = ".cursor/rules",
						gist_ids = {},
					})
					local content = rules.format(rule_files)
					return [[#buffer]] .. "\n\n" .. content
				end,
			},
		},
	},
	["inline"] = {
		strategy = "inline",
		description = "The default inline with nice context",
		opts = {
			short_name = "inline",
			user_prompt = true,
			ignore_system_prompt = false,
			contains_code = true,
		},
		prompts = {
			{
				role = "user",
				content = [[#buffer]],
			},
		},
		-- references = {
		--   {
		--     type = "file",
		--     path = ".github/copilot-instructions.md",
		--   },
		-- },
	},
}

local slash_commands = require("plugin.llm.codecompanion.slash_commands")
local keys = {
	{
		"<leader>aa",
		function()
			local mode = vim.api.nvim_get_mode().mode
			if mode == "v" or mode == "V" or mode == "\22" then -- visual, visual-line, visual-block
				vim.cmd("CodeCompanionChat Add")
			else
				vim.cmd("CodeCompanionChat")
			end
		end,
		desc = "[a]i ch[a]t",
		mode = { "n", "v" },
	},
	{
		"<leader>ac",
		function()
			require("codecompanion").prompt("def")
		end,
		desc = "[a]i ch[a]t",
		mode = { "n", "v" },
	},
	{
		desc = "[a]i [q]uick chat",
		"<leader>aq",
		function()
			require("codecompanion").prompt("inline")
		end,
		mode = { "n", "v" },
	},
	{
		"<leader>ac",
		function()
			require("codecompanion").actions({})
		end,
		desc = "[a]i [c]ommands",
		mode = { "n", "v" },
	},
	{
		"<leader>ad",
		function()
			require("codecompanion").prompt("dynamic")
		end,
		desc = "[a]i [d]ynamic prompt",
		mode = { "n", "v" },
	},
	{
		"<leader>at",
		function()
			require("codecompanion").toggle()
		end,
		desc = "[a]i [t]oggle chat",
		mode = { "n", "v" },
	},
	{
		"<leader>ah",
		function()
			vim.cmd("CodeCompanionHistory")
		end,
		desc = "[a]i [h]istory",
		mode = { "n" },
	},
}

require("which-key").add(keys)

--- treesitter for chat buffers
--- NOTE remove when this PR is merged #1547
vim.api.nvim_create_autocmd("User", {
	pattern = "CodeCompanionChatCreated",
	group = vim.api.nvim_create_augroup("my-codecompanion-chat", { clear = true }),
	callback = function(event)
		vim.treesitter.start(event.data.bufnr, "markdown")
	end,
})

require("codecompanion").setup({
	strategies = {
		chat = {
			slash_commands = slash_commands,
			variables = {},
			tools = tools,
			keymaps = {
				close = {
					modes = { n = { "q", "<C-c>" }, i = "<C-c>" },
				},
			},
		},
		inline = {
			slash_commands = slash_commands,
			tools = {},
			keymaps = {
				accept_change = {
					modes = { n = "ca" },
					description = "Accept the suggested change",
				},
				reject_change = {
					modes = { n = "cs" },
					description = "Reject the suggested change",
				},
			},
		},
	},
	display = {
		opts = {},
		chat = {
			icons = {
				separator = "─",
				auto_scroll = true,
				pinned_buffer = "📌 ",
				watched_buffer = "👀 ",
			},
			show_settings = true,
			window = {
				position = "right",
			},
		},
		diff = {
			enabled = true,
		},
		action_palette = {
			width = 95,
			height = 10,
			prompt = "Prompt ",
			provider = "telescope",
			opts = {
				show_default_actions = true,
				show_default_prompt_library = true,
			},
		},
	},
	opts = {
		log_level = "DEBUG",
		send_code = true,
		system_prompt = require("plugin.llm.codecompanion.system_prompt"),
	},
	extensions = {
		mcphub = {
			enabled = true,
			auto_approve = true,
			callback = "mcphub.extensions.codecompanion",
			opts = {
				show_result_in_chat = true, -- Show mcp tool results in chat
				make_vars = true, -- Convert resources to #variables
				make_slash_commands = true, -- Add prompts as /slash commands
			},
		},
		history = {
			enabled = true,
			opts = {
				keymap = "ah",
				auto_save = true,
				picker = "fzf-lua",
				auto_generate_title = true,
				title_generation_opts = {
					adapter = nil, -- "copilot"
					---Model for generating titles (defaults to current chat model)
					model = nil, -- "gpt-4o"
					refresh_every_n_prompts = 0, -- e.g., 3 to refresh after every 3rd user prompt
					max_refreshes = 3,
				},
				continue_last_chat = false,
				---When chat is cleared with `gx` delete the chat from history
				delete_on_clearing_chat = false,
				---Directory path to save the chats
				dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
				---Enable detailed logging for history extension
				enable_logging = false,
			},
		},
	},
})
