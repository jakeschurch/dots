require("colorful-menu").setup()
local lspkind = require("lspkind")

require("blink.cmp").setup({
  cmdline = {
    keymap = {
      ["<Tab>"] = { "accept" },
    },
    completion = { menu = { auto_show = true } },
  },
  sources = {
    default = {
      -- "buffer",
      "lsp",
      "copilot",
      "path",
      "snippets",
      "emoji",
    },

    min_keyword_length = 1,
    providers = {

      copilot = {
        name = "copilot",
        module = "blink-copilot",
        score_offset = 100,
        async = true,
      },

      emoji = {
        module = "blink-emoji",
        name = "Emoji",
        score_offset = 15, -- Tune by preference
        opts = { insert = true }, -- Insert emoji (default) or complete its name
        should_show_items = function()
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
  completion = {
    keyword = { range = "prefix" },
    list = {
      selection = { preselect = false, auto_insert = true },
    },
    trigger = {
      show_on_trigger_character = true,
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
        max_width = 40,
        border = "single",
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
    window = { border = "single", max_width = 60 },
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
})
