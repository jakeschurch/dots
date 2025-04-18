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
})
