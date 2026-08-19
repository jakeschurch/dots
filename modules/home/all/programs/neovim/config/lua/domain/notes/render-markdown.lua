require("render-markdown").setup({
  completions = { blink = { enabled = true } },
  file_types = { "markdown", "vimwiki", "help" },
  quote = {
    enabled = true,
    repeat_linebreak = true,
    icon = "|",
    highlight = "RenderMarkdownQuote",
  },
  heading = {
    sign = false,
    position = "inline",
    width = "block",
  },
  checkbox = {
    checked = { scope_highlight = "@markup.strikethrough" },
  },
  code = {
    sign = false,
    width = "full",
    border = "none",
    left_pad = 2,
    right_pad = 0,
    position = "right",
    language_name = false,
    above = nil,
    below = nil,
    style = "none",
    highlight = "none",
    highlight_inline = "none",
  },
  dash = {
    width = 15,
  },
  indent = {
    skip_heading = true,
  },
  bullet = {
    icons = { "●", "○", "◆", "◇" },
  },
  latex = { enabled = false },
})
