require("copilot").setup({
  enabled = true,
  suggestion = {
    enabled = false, -- instead use through blink.cmp
    auto_trigger = false,
  },
  keymap = {
    accept = false,
  },
  filetypes = {
    markdown = true,
    help = true,
  },
  panel = {
    enabled = false,
  },
  copilot_model = "gpt-4o-copilot",
  logger = {
    file_log_level = vim.log.levels.OFF,
    print_log_level = vim.log.levels.OFF,
  },
})
