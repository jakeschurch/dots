-- Inline decorations for wiki prose, in one pass over the buffer:
--
--   @word            wiki tags, matching g:vimwiki_tag_format's `@` pre_mark
--   shortcut URLs    concealed down to `sc-104714`
--
-- Extmarks rather than `syntax match`, because treesitter highlighting is what
-- runs in these buffers and a syntax rule would not survive it.
--
-- render-markdown cannot do the URL half: a bare pasted URL is not a link node
-- at all to the markdown parser, just inline text, and `link.custom` only
-- swaps the icon on a real link — it has no way to rewrite the visible text.

local M = {}

local NS = vim.api.nvim_create_namespace("notes-inline")
local MENTION_HL = "WikiMention"
local LABEL_HL = "WikiLinkLabel"

local FILETYPES = { markdown = true, vimwiki = true }

-- Long service URLs shorten to their native shorthand. Matched in order, and a
-- match overlapping an earlier one is skipped, so put the specific patterns
-- first. Lua patterns have no alternation, hence issues and pulls separately.
local TRAILING = "[^%s%)%]>`]*"

local function issue(owner, repo, number)
  return (" %s/%s#%s"):format(owner, repo, number)
end

local LABELS = {
  {
    pattern = "https?://app%.shortcut%.com/[%w%-_]+/story/(%d+)" .. TRAILING,
    label = function(id)
      return "󰓹 sc-" .. id
    end,
  },
  {
    pattern = "https?://github%.com/([%w%-%._]+)/([%w%-%._]+)/issues/(%d+)"
      .. TRAILING,
    label = issue,
  },
  {
    pattern = "https?://github%.com/([%w%-%._]+)/([%w%-%._]+)/pull/(%d+)"
      .. TRAILING,
    label = issue,
  },
  {
    pattern = "https?://github%.com/([%w%-%._]+)/([%w%-%._]+)/commit/(%x+)"
      .. TRAILING,
    label = function(owner, repo, sha)
      return (" %s/%s@%s"):format(owner, repo, sha:sub(1, 7))
    end,
  },
}

local function set_highlights()
  local palette = require("lib.palette")
  vim.api.nvim_set_hl(0, MENTION_HL, { fg = palette.red, bold = true })
  vim.api.nvim_set_hl(0, LABEL_HL, { fg = palette.blue, underline = true })
end

--- Byte ranges covered by inline `code` spans, so a match inside one is skipped.
local function code_spans(line)
  local spans, from = {}, 1
  while true do
    local open = line:find("`", from, true)
    if not open then
      return spans
    end
    local close = line:find("`", open + 1, true)
    if not close then
      return spans
    end
    spans[#spans + 1] = { open, close }
    from = close + 1
  end
end

local function inside(spans, pos)
  for _, span in ipairs(spans) do
    if pos >= span[1] and pos <= span[2] then
      return true
    end
  end
  return false
end

local function mark(buf, row, first, last, opts)
  pcall(
    vim.api.nvim_buf_set_extmark,
    buf,
    NS,
    row,
    first - 1,
    vim.tbl_extend("force", { end_col = last }, opts)
  )
end

local function decorate(buf, row, line, spans)
  -- Shortened links first: a concealed URL must not also collect mention marks.
  local concealed = {}
  for _, rule in ipairs(LABELS) do
    local from = 1
    while true do
      local found = { line:find(rule.pattern, from) }
      local first, last = found[1], found[2]
      if not first then
        break
      end
      -- Inside `[text](url)` the destination is already hidden by
      -- render-markdown, and the visible text is the author's own.
      local is_destination = line:sub(math.max(1, first - 2), first - 1) == "]("
      if
        not is_destination
        and not inside(spans, first)
        and not inside(concealed, first)
      then
        mark(buf, row, first, last, {
          conceal = "",
          virt_text = {
            { rule.label(unpack(found, 3)), LABEL_HL },
          },
          virt_text_pos = "inline",
        })
        concealed[#concealed + 1] = { first, last }
      end
      from = last + 1
    end
  end

  local from = 1
  while true do
    local first, last = line:find("@[%w][%w_%-]*", from)
    if not first then
      break
    end
    -- An `@` glued to a word is an email, not a tag.
    local prev = first > 1 and line:sub(first - 1, first - 1) or ""
    if
      not prev:match("[%w_]")
      and not inside(spans, first)
      and not inside(concealed, first)
    then
      mark(buf, row, first, last, { hl_group = MENTION_HL })
    end
    from = last + 1
  end
end

---@param buf integer
function M.render(buf)
  if
    not vim.api.nvim_buf_is_valid(buf) or not FILETYPES[vim.bo[buf].filetype]
  then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)

  local fenced = false
  for lnum, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    if line:match("^%s*```") then
      fenced = not fenced
    elseif not fenced then
      decorate(buf, lnum - 1, line, code_spans(line))
    end
  end
end

set_highlights()

local group = vim.api.nvim_create_augroup("notes-inline", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_highlights,
  desc = "Keep inline note colours across colourscheme changes",
})

local pending

vim.api.nvim_create_autocmd(
  { "BufReadPost", "BufWritePost", "TextChanged", "TextChangedI", "FileType" },
  {
    group = group,
    callback = function(ev)
      if pending then
        pending:stop()
      end
      pending = vim.defer_fn(function()
        M.render(ev.buf)
      end, 120)
    end,
    desc = "Highlight @word tags and shorten story links",
  }
)

return M
