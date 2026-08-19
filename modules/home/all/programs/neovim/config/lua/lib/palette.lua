-- Single source of colour for the pills, winbar, lspsaga and TODO highlights.
--
-- Values are read out of the active colorscheme rather than hardcoded, so
-- swapping schemes needs no edits here. The fallbacks are gruvbox soft dark,
-- for the window before a scheme has loaded. Indexing goes through a cache
-- that ColorScheme clears, because lualine bakes colours in at setup time and
-- has to be able to re-read them.

local M = {}

local function hl(name, attr, fallback)
  local ok, group = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  local value = ok and group and group[attr]
  return value and string.format("#%06x", value) or fallback
end

function M.build()
  return {
    bg0 = hl("Normal", "bg", "#32302f"),
    bg1 = hl("CursorLine", "bg", "#3c3836"),
    bg2 = hl("Pmenu", "bg", "#504945"),
    bg3 = hl("PmenuSel", "bg", "#665c54"),

    fg1 = hl("Normal", "fg", "#ebdbb2"),
    fg4 = hl("LineNr", "fg", "#a89984"),
    gray = hl("Comment", "fg", "#928374"),

    red = hl("DiagnosticError", "fg", "#fb4934"),
    yellow = hl("DiagnosticWarn", "fg", "#fabd2f"),
    blue = hl("DiagnosticInfo", "fg", "#83a598"),
    aqua = hl("DiagnosticHint", "fg", "#8ec07c"),
    green = hl("String", "fg", "#b8bb26"),
    purple = hl("@variable.parameter", "fg", "#d3869b"),
    orange = hl("@module", "fg", "#fe8019"),
    accent = hl("@keyword", "fg", "#fe8019"),
  }
end

local cache

local function colors()
  if not cache then
    cache = M.build()
  end
  return cache
end

function M.refresh()
  cache = nil
  return colors()
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("palette", { clear = true }),
  callback = function()
    cache = nil
  end,
  desc = "Re-read the palette from the new colorscheme",
})

return setmetatable(M, {
  __index = function(_, key)
    return colors()[key]
  end,
})
