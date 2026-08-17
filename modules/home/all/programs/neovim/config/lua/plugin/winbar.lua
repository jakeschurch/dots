-- Centered pill winbar: a filename capsule and a parent-directory capsule
-- floating in the middle of the window's top row.
local pills = require("plugin.pills")
local ignored_filetypes = require("utils").ignored_filetypes

local M = {}

local c = pills.colors

-- One capsule holding `dir/name`. The two halves differ only in foreground so
-- the directory recedes without breaking the pill into separate shapes.
local function set_highlights()
  pills.define("WinbarFile", c.bg2, c.fg1, { bold = true })
  pills.define("WinbarFileModified", c.orange, c.bg0, { bold = true })
  vim.api.nvim_set_hl(0, "WinbarFileDim", { bg = c.bg2, fg = c.fg4 })
  vim.api.nvim_set_hl(0, "WinbarFileModifiedDim", { bg = c.orange, fg = c.bg0 })
end

--- Winbar is unwanted in floats, special buffers and anything that draws its
--- own (oil sets a window-local winbar, which wins over the global one).
local function enabled(win, buf)
  if vim.api.nvim_win_get_config(win).relative ~= "" then
    return false
  end
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  if vim.tbl_contains(ignored_filetypes, vim.bo[buf].filetype) then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

---@return string
function M.render()
  local win = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
  if not ok or not enabled(win, buf) then
    return ""
  end

  local path = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(path, ":t")

  local icon = ""
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    icon = devicons.get_icon(
      name,
      vim.fn.fnamemodify(name, ":e"),
      { default = true }
    ) or ""
  end

  local base = vim.bo[buf].modified and "WinbarFileModified" or "WinbarFile"

  local lead = " " .. icon .. " "
  local dir = vim.fn.fnamemodify(path, ":p:h:t")
  if dir ~= "" and dir ~= "." then
    lead = lead .. dir .. "/"
  end

  -- `%=` on both sides centres the capsule.
  return "%="
    .. table.concat({
      "%#" .. base .. "Cap#" .. pills.cap.left,
      "%#" .. base .. "Dim#" .. lead,
      "%#" .. base .. "#" .. name .. " ",
      "%#" .. base .. "Cap#" .. pills.cap.right,
      "%*",
    })
    .. "%="
end

set_highlights()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("winbar-pills", { clear = true }),
  callback = set_highlights,
  desc = "Reapply winbar pill highlights",
})

-- `%{% %}` lets the returned string contain its own `%#Hl#` items.
vim.o.winbar = "%{%v:lua.require'plugin.winbar'.render()%}"

return M
