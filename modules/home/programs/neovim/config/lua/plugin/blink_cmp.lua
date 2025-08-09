require("colorful-menu").setup()
local lspkind = require("lspkind")

local blink_copilot = require("blink-copilot")
blink_copilot.setup({
	max_completions = 3,
	max_attempts = 4,
	debounce = 50,
	auto_refresh = {
		backward = true,
		forward = true,
	},
})

local config = {
	cmdline = {
		keymap = {
			["<Tab>"] = { "accept" },
		},
		completion = { menu = { auto_show = true } },
	},

	sources = {
		default = {
			"buffer",
			"lsp",
			"copilot",
			"path",
			"snippets",
			"emoji",
			"omni",
		},

		per_filetype = {
			markdown = { inherit_defaults = true },
		},

		-- sources.default = function(ctx)
		--   local success, node = pcall(vim.treesitter.get_node)
		--   if success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
		--     return { 'buffer' }
		--   elseif vim.bo.filetype == 'lua' then
		--     return { 'lsp', 'path' }
		--   else
		--     return { 'lsp', 'path', 'snippets', 'buffer' }
		--   end
		-- end

		min_keyword_length = 1,
		providers = {
			copilot = {
				enabled = true,
				min_keyword_length = 0,
				name = "copilot",
				module = "blink-copilot",
				score_offset = 100,
				async = true,
				transform_items = function(_, items)
					local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
					local kind_idx = #CompletionItemKind + 1
					CompletionItemKind[kind_idx] = "Copilot"
					for _, item in ipairs(items) do
						item.kind = kind_idx
					end
					return items
				end,
			},

			emoji = {
				module = "blink-emoji",
				name = "Emoji",
				score_offset = 15, -- Tune by preference
				opts = { insert = true }, -- Insert emoji (default) or complete its name
				enabled = function(_)
					return vim.tbl_contains(
						-- Enable emoji completion only for git commits and markdown.
						-- By default, enabled for all file-types.
						{ "gitcommit", "markdown" },
						vim.o.filetype
					)
				end,
			},

			cmdline = {
				min_keyword_length = function(ctx)
					-- when typing a command, only show when the keyword is 3 characters or longer
					if ctx.mode == "cmdline" and string.find(ctx.line, " ") == nil then
						return 3
					end
					return 1
				end,
			},

			path = {
				opts = {
					get_cwd = function(_)
						return vim.fn.getcwd()
					end,
				},
			},

			buffer = {
				enabled = true,
				opts = {
					get_bufnrs = function()
						return vim.tbl_filter(function(bufnr)
							return vim.bo[bufnr].buftype == ""
						end, vim.api.nvim_list_bufs())
					end,
				},
			},
		},
	},

	fuzzy = {
		implementation = "rust",
		max_typos = function(keyword)
			return math.floor(#keyword / 4)
		end,
		sorts = {
			"exact",
			-- defaults
			"score",
			"sort_text",
		},

		use_proximity = true,
	},

	completion = {
		keyword = { range = "full" },
		accept = { auto_brackets = { enabled = true } },
		list = {
			selection = { preselect = false, auto_insert = true },
		},
		trigger = {
			show_on_trigger_character = true,
			show_on_keyword = true,
		},
		menu = {
			auto_show = true,
			border = "single",
			draw = {
				treesitter = { "lsp" },
				columns = {
					{ "kind_icon" },
					{ "label", gap = 1 },
					{ "label_description" },
					{ "source_name" },
				},
				components = {
					label = {
						text = function(ctx)
							return require("colorful-menu").blink_components_text(ctx)
						end,
						highlight = function(ctx)
							return require("colorful-menu").blink_components_highlight(ctx)
						end,
					},
					kind_icon = {
						ellipsis = false,
						text = function(ctx)
							return lspkind.symbolic(ctx.kind, {
								mode = "symbol",
							})
						end,
					},
				},
			},
		},
		ghost_text = {
			enabled = false,
		},
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 250,
			window = {
				max_width = 50,
				border = nil,
				scrollbar = false,
				direction_priority = {
					menu_north = { "n", "s", "e", "w" },
					menu_south = { "s", "n", "e", "w" },
				},
			},
		},
	},

	signature = {
		enabled = true,
		window = { border = nil, max_width = 60 },
	},
	keymap = {
		["enter"] = nil,
		["<C-c>"] = { "cancel", "hide_documentation" },
		["<C-space>"] = { "select_and_accept" },
		["<C-k>"] = {
			"show",
			"show_documentation",
			"hide_documentation",
			"fallback",
		},
		["<C-y>"] = { "show_signature", "hide_signature", "fallback" },
		["<C-p>"] = { "show", "select_prev", "fallback" },
		["<C-n>"] = { "show", "select_next", "fallback" },
	},
}

local function markdown_transform_items(a, items)
	-- keep case of first char
	local keyword = a.get_keyword()
	local correct, case
	if keyword:match("^%l") then
		correct = "^%u%l+$"
		case = string.lower
	elseif keyword:match("^%u") then
		correct = "^%l+$"
		case = string.upper
	else
		return items
	end

	-- avoid duplicates from the corrections
	local seen = {}
	local out = {}
	for _, item in ipairs(items) do
		local raw = item.insertText
		if raw:match(correct) then
			local text = case(raw:sub(1, 1)) .. raw:sub(2)
			item.insertText = text
			item.label = text
		end
		if not seen[item.insertText] then
			seen[item.insertText] = true
			table.insert(out, item)
		end
	end
	return out
end

config.sources.providers.buffer.transform_items = function(a, items)
	if vim.bo.filetype == "markdown" then
		return markdown_transform_items(a, items)
	end
	return items
end

require("blink.cmp").setup(config)
