vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local oil = require("oil")

local _preview_winid = nil

function ToggleOilPreview()
  if _preview_winid and vim.api.nvim_win_is_valid(_preview_winid) then
    vim.api.nvim_win_close(_preview_winid, true)
    _preview_winid = nil
    return
  end
  local before = vim.api.nvim_list_wins()
  require("oil").open_preview({ split = "belowright" })
  vim.cmd("wincmd h")
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if not vim.tbl_contains(before, win) then
      _preview_winid = win
      break
    end
  end
end

function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require("oil").get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    return vim.api.nvim_buf_get_name(0)
  end
end

oil.setup({
  watch_for_changes = false,
  prompt_save_on_select_new_entry = false,

  win_options = {
    winbar = "%!v:lua.get_oil_winbar()",
    signcolumn = "yes:2",
  },
  columns = {
    "icon",
    "mtime",
  },
  keymaps = {
    ["<leader>hf"] = {
      "actions.cd",
      opts = { scope = "tab" },
      desc = ":tcd to the current oil directory",
    },
    ["<C-p>"] = function()
      ToggleOilPreview()
    end,
    ["<leader>p"] = function()
      local oil = require("oil")
      local filename = oil.get_cursor_entry().name
      local dir = oil.get_current_dir()
      oil.close()

      local img_clip = require("img-clip")
      img_clip.paste_image({}, dir .. filename)
    end,
    ["<C-l>"] = false,
    ["<C-w>"] = false,
    ["<C-h>"] = false,
    ["h"] = "actions.parent",
    ["l"] = "actions.select",
  },
  preview = {
    layout = "right",
    width = 50,
  },
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    case_insensitive = true,
    sort = {
      { "name", "asc" },
    },
  },
  float = {
    preview_split = "right",
  },
  git = {
    -- Return true to automatically git add/mv/rm files
    add = function(path)
      return true
    end,
    mv = function(src_path, dest_path)
      return true
    end,
    rm = function(path)
      return true
    end,
  },
})

require("oil-lsp-diagnostics").setup()
require("oil-git-status").setup()
