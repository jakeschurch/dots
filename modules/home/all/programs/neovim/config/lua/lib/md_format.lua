-- Treesitter-aware paragraph formatting for markdown.
--
-- Vim's built-in gq/gw only knows about blank lines, so `gqap` happily reflows
-- fenced code, mangles tables and glues a heading onto the paragraph beneath
-- it. This walks the markdown block tree instead and hands each prose block to
-- Vim's internal formatter one at a time, so textwidth/formatlistpat/comments
-- still do the actual wrapping.

local M = {}

-- Never reflow these, and never reflow anything containing one.
local BOUNDARY = {
  atx_heading = true,
  setext_heading = true,
  fenced_code_block = true,
  indented_code_block = true,
  html_block = true,
  pipe_table = true,
  link_reference_definition = true,
  thematic_break = true,
  minus_metadata = true, -- yaml frontmatter
  plus_metadata = true, -- toml frontmatter
}

-- Formatted as a unit, so a blockquote never bleeds into the list below it.
local PROSE = {
  paragraph = true,
  list = true,
  block_quote = true,
}

local function contains_boundary(node)
  if BOUNDARY[node:type()] then
    return true
  end
  for child in node:iter_children() do
    if contains_boundary(child) then
      return true
    end
  end
  return false
end

local function collect(node, out)
  if BOUNDARY[node:type()] then
    return
  end

  if PROSE[node:type()] and not contains_boundary(node) then
    local srow, _, erow, ecol = node:range()
    if ecol == 0 then
      erow = erow - 1
    end
    table.insert(out, { srow + 1, erow + 1 })
    return
  end

  for child in node:iter_children() do
    collect(child, out)
  end
end

-- Prose blocks overlapping [first, last], in document order.
local function blocks(first, last)
  local ok, parser = pcall(vim.treesitter.get_parser, 0, "markdown")
  if not ok or not parser then
    return nil
  end

  local parsed, trees = pcall(parser.parse, parser, true)
  if not parsed or not trees or not trees[1] then
    return nil
  end

  local all = {}
  collect(trees[1]:root(), all)

  local out = {}
  for _, range in ipairs(all) do
    local a = math.max(range[1], first)
    local b = math.min(range[2], last)
    if a <= b then
      table.insert(out, { a, b })
    end
  end
  return out
end

function M.format(first, last)
  first = math.max(first, 1)
  last = math.min(last, vim.api.nvim_buf_line_count(0))
  if first > last then
    return
  end

  -- No parser (bare `nvim -u` on a .md, say): fall back to plain gq.
  local ranges = blocks(first, last) or { { first, last } }
  if #ranges == 0 then
    return
  end

  local saved = vim.bo.formatexpr
  vim.bo.formatexpr = ""
  local ok, err = pcall(function()
    -- Bottom-up: reflowing a block shifts every line below it.
    for i = #ranges, 1, -1 do
      vim.cmd(("keepjumps normal! %dGgq%dG"):format(ranges[i][1], ranges[i][2]))
    end
  end)
  vim.bo.formatexpr = saved

  if not ok then
    error(err)
  end
end

-- 'formatexpr' entry point, used by gq.
function M.formatexpr()
  -- Insert-mode auto-wrap: let the internal formatter handle it.
  if vim.v.char ~= "" then
    return 1
  end
  M.format(vim.v.lnum, vim.v.lnum + vim.v.count - 1)
  return 0
end

-- gw keeps the cursor put and ignores 'formatexpr', so drive it via operatorfunc.
function M.opfunc()
  local view = vim.fn.winsaveview()
  M.format(vim.fn.line("'["), vim.fn.line("']"))
  vim.fn.winrestview(view)
end

function M.visual()
  local first = vim.fn.getpos("v")[2]
  local last = vim.fn.line(".")
  if first > last then
    first, last = last, first
  end

  local view = vim.fn.winsaveview()
  vim.cmd("normal! \27")
  M.format(first, last)
  vim.fn.winrestview(view)
end

return M
