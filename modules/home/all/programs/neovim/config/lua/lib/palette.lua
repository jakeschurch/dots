-- Single source of colour for the pills, winbar, lspsaga and TODO highlights.
--
-- Values are read out of the active colorscheme rather than hardcoded, so
-- swapping schemes needs no edits here. The fallbacks are Katmai's, for the
-- window before a scheme has loaded. Indexing goes through a cache that
-- ColorScheme clears, because lualine bakes colours in at setup time and has
-- to be able to re-read them.

local M = {}

local function hl(name, attr, fallback)
  local ok, group = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  local value = ok and group and group[attr]
  return value and string.format("#%06x", value) or fallback
end

function M.build()
  return {
    bg0 = hl("Normal", "bg", "#191512"),
    bg1 = hl("CursorLine", "bg", "#201c19"),
    bg2 = hl("Pmenu", "bg", "#24201d"),
    bg3 = hl("PmenuSel", "bg", "#2c2723"),

    fg1 = hl("Normal", "fg", "#e5ddd2"),
    fg4 = hl("LineNr", "fg", "#726c66"),
    gray = hl("Comment", "fg", "#9d968e"),

    red = hl("DiagnosticError", "fg", "#d85854"),
    yellow = hl("DiagnosticWarn", "fg", "#ddb850"),
    blue = hl("DiagnosticInfo", "fg", "#6c99d0"),
    aqua = hl("DiagnosticHint", "fg", "#60b4ad"),
    green = hl("String", "fg", "#8aaf5d"),
    purple = hl("@variable.parameter", "fg", "#b187c5"),
    orange = hl("@module", "fg", "#df8944"),
    accent = hl("@keyword", "fg", "#e07a5a"),
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
