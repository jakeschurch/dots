local lualine = require("lualine")
local ignored_filetypes = require("utils").ignored_filetypes

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

lualine.setup({
  options = {
    theme = "auto",
    icons_enabled = true,
    globalstatus = true,
    disabled_filetypes = { statusline = ignored_filetypes },
    always_show_tabline = false,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      {
        "branch",
        fmt = function(str)
          local short_prefix = str:gsub("%a+/", "")
          if string.len(short_prefix) > 15 then
            return short_prefix:sub(1, 15) .. " ..."
          else
            return short_prefix
          end
        end,
      },
      { "diff", source = diff_source },
      { "diagnostics" },
    },
    lualine_c = {
      { "filename", path = 1 }, -- relative path
    },
    lualine_x = {
      {
        function()
          local clients = vim.lsp.get_clients({ bufnr = 0 })
          if #clients == 0 then
            return ""
          end
          return "󰿘 " .. clients[1].name
        end,
      },
      "searchcount",
      "filetype",
    },
    lualine_y = { "os.date('%d-%b %H:%M')", "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { { "filename", path = 1 } },
    lualine_x = { "location" },
    lualine_y = { "selectioncount" },
    lualine_z = {},
  },
})
