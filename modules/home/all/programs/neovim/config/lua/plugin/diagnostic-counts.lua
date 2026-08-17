-- Collapsed diagnostic counts on every line that has them, as a small pill at
-- end of line. The cursor's own line is deliberately skipped:
-- tiny-inline-diagnostic expands that one into the full message, so moving onto
-- a line trades its count pill for the detail.
local pills = require("plugin.pills")

local M = {}

local ns = vim.api.nvim_create_namespace("diagnostic-count-pills")
local c = pills.colors

local groups = {
  [vim.diagnostic.severity.ERROR] = { name = "DiagCountError", color = c.red },
  [vim.diagnostic.severity.WARN] = { name = "DiagCountWarn", color = c.yellow },
  [vim.diagnostic.severity.INFO] = { name = "DiagCountInfo", color = c.blue },
  [vim.diagnostic.severity.HINT] = { name = "DiagCountHint", color = c.aqua },
}

local function set_highlights()
  for _, group in pairs(groups) do
    pills.define(group.name, group.color, c.bg0, { bold = true })
  end
end

--- Highest severity wins the pill's colour; the count covers every diagnostic
--- on the line regardless of severity.
---@param buf integer
---@return table<integer, {count: integer, severity: integer}>
local function summarise(buf)
  local by_line = {}
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    local entry = by_line[d.lnum]
    if entry then
      entry.count = entry.count + 1
      entry.severity = math.min(entry.severity, d.severity)
    else
      by_line[d.lnum] = { count = 1, severity = d.severity }
    end
  end
  return by_line
end

---@param buf integer
function M.render(buf)
  -- `0` is truthy in Lua and is not a real buffer id to `bufwinid()`, so it has
  -- to be resolved rather than passed through with `or`.
  if not buf or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted then
    return
  end

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  -- Only skip the cursor line in the window actually showing this buffer.
  local skip = -1
  local win = vim.fn.bufwinid(buf)
  if win ~= -1 then
    skip = vim.api.nvim_win_get_cursor(win)[1] - 1
  end

  local last = vim.api.nvim_buf_line_count(buf) - 1
  for lnum, entry in pairs(summarise(buf)) do
    if lnum ~= skip and lnum <= last then
      local group = groups[entry.severity]
        or groups[vim.diagnostic.severity.HINT]
      pcall(vim.api.nvim_buf_set_extmark, buf, ns, lnum, 0, {
        virt_text = {
          { "  ", "Normal" },
          { pills.cap.left, group.name .. "Cap" },
          { "● " .. entry.count, group.name },
          { pills.cap.right, group.name .. "Cap" },
        },
        virt_text_pos = "eol",
        hl_mode = "combine",
        priority = 100,
      })
    end
  end
end

set_highlights()

local augroup =
  vim.api.nvim_create_augroup("diagnostic-count-pills", { clear = true })

vim.api.nvim_create_autocmd("ColorScheme", {
  group = augroup,
  callback = set_highlights,
  desc = "Reapply diagnostic count pill highlights",
})

vim.api.nvim_create_autocmd(
  { "DiagnosticChanged", "BufEnter", "InsertLeave" },
  {
    group = augroup,
    callback = function(ev)
      M.render(ev.buf)
    end,
    desc = "Refresh diagnostic count pills",
  }
)

-- CursorMoved fires constantly; only the line matters, since that is what
-- decides which pill gets swapped for the expanded message.
vim.api.nvim_create_autocmd("CursorMoved", {
  group = augroup,
  callback = function(ev)
    local line = vim.api.nvim_win_get_cursor(0)[1]
    if vim.b[ev.buf].diagnostic_count_line ~= line then
      vim.b[ev.buf].diagnostic_count_line = line
      M.render(ev.buf)
    end
  end,
  desc = "Swap the cursor line's count pill for the expanded diagnostic",
})

return M
