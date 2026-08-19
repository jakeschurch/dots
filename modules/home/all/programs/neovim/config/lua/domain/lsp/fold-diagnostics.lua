-- tiny-inline-diagnostic has no fold awareness: with `multilines.always_show`
-- it puts a mark on every diagnostic line, so every mark belonging to a line
-- hidden inside a closed fold surfaces together on the fold's single visible
-- row — the same icon repeated once per hidden diagnostic.
--
-- Drop the plugin's marks inside a closed fold and replace them with one
-- summary on the fold's visible row: a single icon per severity, with a count.
local M = {}

local NS = vim.api.nvim_create_namespace("fold-diagnostics")

local severity = vim.diagnostic.severity

local ORDER = {
  severity.ERROR,
  severity.WARN,
  severity.INFO,
  severity.HINT,
}

local HL = {
  [severity.ERROR] = "DiagnosticError",
  [severity.WARN] = "DiagnosticWarn",
  [severity.INFO] = "DiagnosticInfo",
  [severity.HINT] = "DiagnosticHint",
}

--- Reuse the sign glyphs configured in domain/lsp/lsp.lua.
---@return table<integer, string>
local function icons()
  local config = vim.diagnostic.config() or {}
  return (type(config.signs) == "table" and config.signs.text) or {}
end

--- The plugin creates its namespaces lazily, so resolve them on demand rather
--- than at load time.
---@return integer[]
local function namespaces()
  local ids = {}
  for name, id in pairs(vim.api.nvim_get_namespaces()) do
    if name:lower():find("tiny", 1, true) then
      ids[#ids + 1] = id
    end
  end
  return ids
end

--- Counts per severity for diagnostics on 1-indexed lines [first, last].
local function tally(buf, first, last)
  local counts, total = {}, 0
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    local lnum = d.lnum + 1
    if lnum >= first and lnum <= last then
      counts[d.severity] = (counts[d.severity] or 0) + 1
      total = total + 1
    end
  end
  return counts, total
end

local function summary(counts)
  local glyphs = icons()
  local chunks = {}
  for _, sev in ipairs(ORDER) do
    local n = counts[sev]
    if n then
      local glyph = glyphs[sev] or ""
      table.insert(chunks, { (" %s%d"):format(glyph, n), HL[sev] })
    end
  end
  return chunks
end

---@param win integer
function M.clean(win)
  if not vim.api.nvim_win_is_valid(win) then
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  if not vim.api.nvim_buf_is_valid(buf) or not vim.wo[win].foldenable then
    return
  end

  local ids = namespaces()
  vim.api.nvim_buf_clear_namespace(buf, NS, 0, -1)

  vim.api.nvim_win_call(win, function()
    -- Only the visible range matters, and scanning it keeps this bounded by
    -- window height rather than buffer size.
    local lnum = vim.fn.line("w0")
    local bottom = vim.fn.line("w$")
    while lnum <= bottom do
      local start = vim.fn.foldclosed(lnum)
      if start == -1 then
        lnum = lnum + 1
      else
        local stop = vim.fn.foldclosedend(lnum)

        -- 1-indexed [start, stop] is the fold; 0-indexed [start-1, stop) for
        -- the extmark API.
        for _, ns in ipairs(ids) do
          pcall(vim.api.nvim_buf_clear_namespace, buf, ns, start - 1, stop)
        end

        local counts, total = tally(buf, start, stop)
        if total > 0 then
          pcall(vim.api.nvim_buf_set_extmark, buf, NS, start - 1, 0, {
            virt_text = summary(counts),
            virt_text_pos = "eol",
            hl_mode = "combine",
            priority = 2048,
          })
        end

        lnum = stop + 1
      end
    end
  end)
end

local augroup = vim.api.nvim_create_augroup("fold-diagnostics", {
  clear = true,
})

-- The plugin redraws on a throttle (20ms by default), so clearing on the next
-- tick just gets overwritten. Wait past it, and debounce so a burst of cursor
-- movement only cleans once.
local DELAY_MS = 60
local generation = 0

local function schedule_clean()
  local win = vim.api.nvim_get_current_win()
  generation = generation + 1
  local mine = generation
  vim.defer_fn(function()
    if mine == generation then
      M.clean(win)
    end
  end, DELAY_MS)
end

vim.api.nvim_create_autocmd({
  "CursorMoved",
  "CursorHold",
  "WinScrolled",
  "BufEnter",
  "DiagnosticChanged",
}, {
  group = augroup,
  callback = schedule_clean,
  desc = "Summarise inline diagnostics hidden inside closed folds",
})

-- There is no fold event, so `zc`/`zo` with a stationary cursor would not
-- otherwise trigger a pass.
vim.on_key(function(key)
  if key == "z" and vim.api.nvim_get_mode().mode == "n" then
    schedule_clean()
  end
end, NS)

return M
