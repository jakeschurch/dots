require("render-markdown").setup({
  render_modes = true,
  quote = {
    enabled = true,
    repeat_linebreak = true,
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
    width = "block",
    left_pad = 2,
    right_pad = 2,
    position = "right",
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

local group = vim.api.nvim_create_augroup("markdown", { clear = true })

for _, keyword in ipairs(keywords) do
  local callout_keyword = "[!" .. keyword .. "]"

  local keyword_variations = {
    keyword,
    keyword:lower(),
    keyword:upper(),
    keyword .. ":",
    keyword:lower() .. ":",
  }

  for _, kw_variant in ipairs(keyword_variations) do
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "*.md", "*.wiki" },
      group = group,
      command = "iabbrev " .. kw_variant .. " " .. callout_keyword,
    })
  end
end
