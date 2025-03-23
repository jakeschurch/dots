require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
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
    chat = {
      window = {
        layout = "float",
      },
    },
    diff = {
      enabled = false,
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
