vim.g.codecompanion_auto_tool_mode = true

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
      require("codecompanion").actions({})
    end,
    desc = "[a]i [c]ommands",
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

require("codecompanion").setup({
  interactions = {
    chat = {
      adapter = "opencode",
      opts = {
        completion_provider = "blink",
      },
      variables = {
        ["buffer"] = {
          opts = {
            -- Always sync the buffer by sharing its "diff"
            -- Or choose "all" to share the entire buffer
            default_params = "all",
          },
        },
      },
    },
    inline = {
      adapter = "opencode",
      opts = {
        completion_provider = "blink",
      },
    },
    cmd = {
      adapter = "opencode",
      opts = {
        completion_provider = "blink",
      },
    },
  },

  strategies = {
    chat = {
      adapter = "opencode",
      -- slash_commands = slash_commands,
      -- tools = tools,
      keymaps = {
        close = {
          modes = { n = { "q", "<C-c>" }, i = "<C-c>" },
        },
      },
    },
    inline = {
      adapter = "opencode",
      -- slash_commands = slash_commands,
      -- tools = {},
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
      show_settings = false,
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
      provider = "fzf_lua",
      opts = {
        show_default_actions = true,
        show_default_prompt_library = true,
      },
    },
  },

  opts = {
    log_level = "DEBUG",
    send_code = true,
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
          adapter = "copilot", -- "copilot"
          ---Model for generating titles (defaults to current chat model)
          -- model = nil,                 -- "gpt-4o"
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
