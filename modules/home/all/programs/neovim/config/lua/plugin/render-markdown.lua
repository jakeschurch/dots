require("render-markdown").setup({
  completions = { blink = { enabled = true } },
  file_types = { "markdown", "vimwiki", "Avante", "help", "codecompanion" },
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

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

local keywords = {
  "NOTE",
  "TIP",
  "IMPORTANT",
  "WARNING",
  "CAUTION",
  "ABSTRACT",
  "SUMMARY",
  "TLDR",
  "INFO",
  "TODO",
  "HINT",
  "SUCCESS",
  "CHECK",
  "DONE",
  "QUESTION",
  "HELP",
  "FAQ",
  "ATTENTION",
  "FAILURE",
  "FAIL",
  "MISSING",
  "DANGER",
  "ERROR",
  "BUG",
  "EXAMPLE",
  "QUOTE",
  "CITE",
}

local snippets = {}

for _, keyword in ipairs(keywords) do
  local callout = "> [!" .. keyword .. "]"
  local variations = {
    keyword,
    keyword:lower(),
    keyword:upper(),
    keyword .. ":",
    keyword:lower() .. ":",
  }
  for _, trig in ipairs(variations) do
    table.insert(
      snippets,
      s(
        { trig = trig, wordTrig = true, snippetType = "autosnippet" },
        { t(callout) }
      )
    )
  end
end

return snippets
