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
  -- render-markdown owns these and restores its captured default whenever it
  -- is not rendering, so setting conceallevel in the ftplugin gets clobbered.
  -- 2 rather than 0 keeps the shortened story links hidden with rendering off;
  -- an empty concealcursor reveals the raw URL on the cursor's own line.
  win_options = {
    conceallevel = { default = 2, rendered = 3 },
    concealcursor = { default = "", rendered = "" },
  },
  -- Only applies to real link nodes — `<url>` and `[text](url)`. A bare pasted
  -- URL is plain inline text to the parser; domain/notes/inline.lua covers it.
  link = {
    custom = {
      shortcut = { pattern = "app%.shortcut%.com", icon = "󰓹 " },
      github = { pattern = "github%.com", icon = " " },
      terraform = { pattern = "registry%.terraform%.io", icon = "󱁢 " },
      aws = { pattern = "aws%.amazon%.com", icon = " " },
      k8s = { pattern = "kubernetes%.io", icon = "󱃾 " },
    },
  },
})
