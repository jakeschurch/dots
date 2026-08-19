local M = {}

---@return {name:string, text:string, texthl:string}[]
function M.get_signs(win)
  local buf = vim.api.nvim_win_get_buf(win)
  local lnum = vim.v.lnum
  local signs = {}

  if vim.fn.has("nvim-0.10") == 0 then
    -- Only needed for Neovim <0.10
    -- Newer versions include legacy signs in nvim_buf_get_extmarks
    for _, sign in
      ipairs(vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs)
    do
      local ret = vim.fn.sign_getdefined(sign.name)[1]
      if ret then
        ret.priority = sign.priority
        signs[#signs + 1] = ret
      end
    end
  end

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

function M.column()
  local win = vim.g.statusline_winid
  if vim.wo[win].signcolumn == "no" then
    return ""
  end
  local sign, git_sign
  for _, s in ipairs(M.get_signs(win)) do
    if s.name:find("GitSign") then
      git_sign = s
    elseif not s.name:find("Diagnostic") then
      -- Diagnostics are shown as inline pills, so they are dropped here rather
      -- than undefined in vim.diagnostic.config: tiny-inline-diagnostic still
      -- needs their icons. Other signs (marks, dap breakpoints) are unaffected.
      sign = s
    end
  end

  -- Only closed folds get a marker. 'foldmethod' is treesitter's expression
  -- with foldlevel=99, so nearly every block is an *open* fold — marking those
  -- decorates most of the file without telling you anything.
  local fold = " "
  if vim.fn.foldclosed(vim.v.lnum) >= 0 then
    fold = vim.opt.fillchars:get().foldclose or " "
  end

  local nu = " "
  if vim.wo[win].number and vim.wo[win].relativenumber then
    if vim.v.virtnum == 0 then
      nu = vim.v.relnum == 0 and vim.v.lnum .. [[%=]]
        or ([[%=]] .. vim.v.relnum)
    elseif vim.v.virtnum > 0 then
      nu = [[%=]]
    else
      vim.notify_once("Hit vim.v.virtnum < 0", vim.log.levels.WARN)
    end
  end

  -- Exactly one cell per marker so the column keeps a fixed width whether or
  -- not a sign is present; the old code mixed one-cell glyphs with two-space
  -- blanks, which shifted the text by a column.
  ---@param s table|nil
  ---@return string
  local function cell(s)
    if not s then
      return " "
    end
    local text = vim.trim(s.text or "")
    if text == "" then
      return " "
    end
    return "%#" .. (s.texthl or "Normal") .. "#" .. text .. "%*"
  end

  -- Signs and number keep their existing positions; only the fold marker moves,
  -- from the far left to the far right where it sits beside the code it folds.
  local components = {
    cell(sign),
    nu,
    cell(git_sign),
    "%#StatusColumnFold#" .. fold .. "%*",
  }
  return table.concat(components, "")
end

-- FoldColumn carries a background of its own, which would paint a band down
-- the whole gutter because the fold cell is drawn on every line. Borrow its
-- foreground and drop the background so only the glyph is coloured.
local function set_fold_highlight()
  local fold_hl = vim.api.nvim_get_hl(0, { name = "FoldColumn", link = false })
  vim.api.nvim_set_hl(0, "StatusColumnFold", { fg = fold_hl.fg, bg = "NONE" })
end

set_fold_highlight()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("statuscolumn-fold", { clear = true }),
  callback = set_fold_highlight,
  desc = "Keep the fold marker's background clear",
})

return M
