-- `@word` wiki tags, matching g:vimwiki_tag_format's `@` pre_mark.
--
-- Extmarks rather than `syntax match`, because treesitter highlighting is what
-- runs in these buffers and a syntax rule would not survive it. The old
-- FileType-vimwiki rule never fired at all: after/ftplugin/vimwiki.vim switches
-- the filetype to markdown before it could match.

local M = {}

local NS = vim.api.nvim_create_namespace("wiki-mentions")
local HL = "WikiMention"

local FILETYPES = { markdown = true, vimwiki = true }

local function set_highlight()
  vim.api.nvim_set_hl(0, HL, { fg = require("lib.palette").red, bold = true })
end

--- Byte ranges covered by inline `code` spans, so a tag inside one is skipped.
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
    table.insert(spans, { open, close })
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
      local spans = code_spans(line)
      local from = 1
      while true do
        local first, last = line:find("@[%w][%w_%-]*", from)
        if not first then
          break
        end
        -- An `@` glued to a word is an email, not a tag.
        local prev = first > 1 and line:sub(first - 1, first - 1) or ""
        if not prev:match("[%w_]") and not inside(spans, first) then
          pcall(vim.api.nvim_buf_set_extmark, buf, NS, lnum - 1, first - 1, {
            end_col = last,
            hl_group = HL,
          })
        end
        from = last + 1
      end
    end
  end
end

set_highlight()

local group = vim.api.nvim_create_augroup("wiki-mentions", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = group,
  callback = set_highlight,
  desc = "Keep the mention colour across colourscheme changes",
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
    desc = "Highlight @word wiki tags",
  }
)

return M
