require("render-markdown").setup({
  file_types = { "markdown", "vimwiki", "Avante" },
  quote = {
    enabled = true,
    repeat_linebreak = true,
    icon = ">",
    highlight = "RenderMarkdownQuote",
  },
  heading = {
    sign = false,
    position = "inline",
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
