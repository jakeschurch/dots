vim.api.nvim_set_hl(0, "Search", {})
vim.api.nvim_set_hl(0, "CurSearch", {})
local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

require("lualine").setup({
  options = {
    theme = "gruvbox",
    icons_enabled = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "branch",
        fmt = function(str)
          local short_prefix = str:gsub("%a+/", "")
          if string.len(short_prefix) > 12 then
            return short_prefix:sub(1, 12) .. " ..."
          else
            return short_prefix
          end
        end,
      },
      { "diff", source = diff_source },
      {
        "diagnostics",
        require("lsp-status").diagnostics,
      },
    },
    lualine_c = {
      "filename",
      "searchcount",
      "selectioncount",
    },
    lualine_x = { "filetype" },
    lualine_y = { "os.date('%d-%b %r')", "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
})
