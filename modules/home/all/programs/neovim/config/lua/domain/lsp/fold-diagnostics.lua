-- tiny-inline-diagnostic has no fold awareness: with `multilines.always_show`
-- it puts a mark on every diagnostic line, so the marks belonging to lines
-- hidden inside a closed fold surface together on the fold's single visible
-- row. Strip the marks that fall inside a closed fold, keeping the one on the
-- fold's first line so the fold still reports something.
local M = {}

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
  if #ids == 0 then
    return
  end

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
        -- 1-indexed lines [start+1, stop] are the hidden ones, which is
        -- 0-indexed [start, stop) for the extmark API.
        for _, ns in ipairs(ids) do
          pcall(vim.api.nvim_buf_clear_namespace, buf, ns, start, stop)
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
  desc = "Drop inline diagnostics hidden inside closed folds",
})

return M
