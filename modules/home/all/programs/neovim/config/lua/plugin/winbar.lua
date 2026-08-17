-- Centered pill winbar: a filename capsule and a parent-directory capsule
-- floating in the middle of the window's top row.
local pills = require("plugin.pills")
local ignored_filetypes = require("utils").ignored_filetypes

local M = {}

local c = pills.colors

local function set_highlights()
  pills.define("WinbarFile", c.fg1, c.bg0, { bold = true })
  pills.define("WinbarFileModified", c.orange, c.bg0, { bold = true })
  pills.define("WinbarDir", c.bg2, c.fg4)
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

  local file_hl = vim.bo[buf].modified and "WinbarFileModified" or "WinbarFile"
  local segments = { pills.render(file_hl, icon .. " " .. name) }

  local dir = vim.fn.fnamemodify(path, ":p:h:t")
  if dir ~= "" and dir ~= "." then
    table.insert(segments, pills.render("WinbarDir", "󰉋 " .. dir))
  end

  -- `%=` on both sides centres the group.
  return "%=" .. table.concat(segments, " ") .. "%="
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
