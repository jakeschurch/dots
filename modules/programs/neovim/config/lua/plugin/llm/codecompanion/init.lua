require("plugin.llm.codecompanion.lualine_integration"):init()

local prompts = {
  -- ["rfc"] = require("plugin.llm.codecompanion.prompts.rfc"),
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
          local rule_files = rules.get_project_rules(context.filename, {
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
}

require("which-key").add(keys)

require("codecompanion").setup({
  prompt_library = prompts,
  strategies = {
    chat = {
      adapter = "copilot",
      slash_commands = slash_commands,
      variables = {},
      roles = {
        ---@type string|fun(adapter: CodeCompanion.Adapter): string
        llm = function(llm)
          return llm.formatted_name .. "(" .. llm.schema.model.default .. ")"
        end,
      },
      keymaps = {
        close = {
          modes = { n = { "q", "<C-c>" }, i = "<C-c>" },
        },
      },
    },
    inline = {
      adapter = "copilot",
      slash_commands = slash_commands,
      tools = tools,
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
    opts = {
      system_prompt = require("plugin.llm.codecompanion.system_prompt"),
    },
    chat = {
      icons = {
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
})
