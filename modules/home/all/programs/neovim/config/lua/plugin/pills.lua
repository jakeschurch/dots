-- Shared palette + pill primitives for the statusline and winbar.
--
-- A "pill" is a rounded capsule: the round powerline caps ( U+E0B6 and
--  U+E0B4) are drawn as *foreground* in the pill's fill colour against a
-- transparent bar, so the buffer shows through the gaps between pills.
local M = {}

-- gruvbox soft dark. Hardcoded to match the active colorscheme; if the
-- colorscheme changes, update here (lualine bakes colours in at setup time).
M.colors = {
  bg0 = "#32302f",
  bg1 = "#3c3836",
  bg2 = "#504945",
  bg3 = "#665c54",
  fg1 = "#ebdbb2",
  fg4 = "#a89984",
  gray = "#928374",
  red = "#fb4934",
  green = "#b8bb26",
  yellow = "#fabd2f",
  blue = "#83a598",
  purple = "#d3869b",
  aqua = "#8ec07c",
  orange = "#fe8019",
}

-- Round powerline caps (U+E0B6 / U+E0B4). These live in the Powerline Extra
-- Symbols range, so they need a Nerd Font. Without one they render as tofu
-- boxes; set `rounded = false` to fall back to plain padded blocks, which still
-- read as capsules because the fill colour does the work.
M.rounded = true

-- Built from codepoints rather than written literally: these live in the BMP
-- Private Use Area and do not survive every editor/formatter round-trip, which
-- silently leaves empty strings and no caps at all.
M.cap = M.rounded
    and { left = vim.fn.nr2char(0xE0B6), right = vim.fn.nr2char(0xE0B4) }
  or { left = " ", right = " " }

--- The bar's own background. "NONE" does *not* mean transparent on an opaque
--- terminal — it falls through to the theme's StatusLine highlight, which is a
--- solid bar. Using the real Normal background is what makes pills look like
--- they float over the buffer.
---@return string
function M.bar_bg()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
  if normal and normal.bg then
    return string.format("#%06x", normal.bg)
  end
  return M.colors.bg0
end

--- Define a pill's highlight groups: the body, and the caps that fake the
--- rounded ends by inverting fg/bg.
---@param name string base highlight group name
---@param fill string background colour of the pill
---@param fg string text colour
---@param opts? table extra nvim_set_hl attributes for the body
function M.define(name, fill, fg, opts)
  local body = vim.tbl_extend("force", { bg = fill, fg = fg }, opts or {})
  vim.api.nvim_set_hl(0, name, body)
  vim.api.nvim_set_hl(0, name .. "Cap", { fg = fill, bg = M.bar_bg() })
end

--- Render a pill as a statusline/winbar expression string.
---@param name string base highlight group name (as passed to M.define)
---@param text string
---@return string
function M.render(name, text)
  return table.concat({
    "%#" .. name .. "Cap#" .. M.cap.left,
    "%#" .. name .. "#" .. text,
    "%#" .. name .. "Cap#" .. M.cap.right,
    "%*",
  })
end

return M
