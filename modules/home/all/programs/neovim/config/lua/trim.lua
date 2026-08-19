local M = {}

-- Zero-width, non-breaking and exotic spaces. LLM output is full of these.
local INVISIBLE = {
  ["\u{00a0}"] = " ", -- no-break space
  ["\u{202f}"] = " ", -- narrow no-break space
  ["\u{2007}"] = " ", -- figure space
  ["\u{2009}"] = " ", -- thin space
  ["\u{200a}"] = " ", -- hair space
  ["\u{3000}"] = " ", -- ideographic space
  ["\u{00ad}"] = "", -- soft hyphen
  ["\u{200b}"] = "", -- zero-width space
  ["\u{200c}"] = "", -- zero-width non-joiner
  ["\u{200d}"] = "", -- zero-width joiner
  ["\u{2060}"] = "", -- word joiner
  ["\u{feff}"] = "", -- zero-width no-break space / BOM
  ["\u{2028}"] = "", -- line separator
  ["\u{2029}"] = "", -- paragraph separator
}

-- Filetypes where two trailing spaces are a hard line break.
local KEEP_HARD_BREAK = {
  markdown = true,
  vimwiki = true,
  rmd = true,
  quarto = true,
}

local SKIP = {
  diff = true,
  mail = true,
  gitsendemail = true,
}

local function clean(line, keep_hard_break)
  for needle, repl in pairs(INVISIBLE) do
    line = line:gsub(needle, repl)
  end

  local body, trail = line:match("^(.-)([ \t]*)$")
  if keep_hard_break and trail == "  " and body ~= "" then
    return body .. "  "
  end
  return body
end

function M.buffer(buf)
  buf = buf or 0
  if vim.bo[buf].binary or vim.bo[buf].buftype ~= "" then
    return
  end

  local ft = vim.bo[buf].filetype
  if SKIP[ft] then
    return
  end

  local keep_hard_break = KEEP_HARD_BREAK[ft] or false
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local changed = false

  for i, line in ipairs(lines) do
    local cleaned = clean(line, keep_hard_break)
    if cleaned ~= line then
      lines[i] = cleaned
      changed = true
    end
  end

  -- Collapse trailing blank lines down to a single terminating newline.
  local last = #lines
  while last > 1 and lines[last] == "" do
    last = last - 1
  end
  if last < #lines then
    lines = vim.list_slice(lines, 1, last)
    changed = true
  end

  if changed then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  end
end

return M
