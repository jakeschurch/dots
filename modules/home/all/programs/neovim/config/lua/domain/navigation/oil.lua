vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local oil = require("oil")

function _G.get_oil_winbar()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = oil.get_current_dir(bufnr)
  if dir then
    return vim.fn.fnamemodify(dir, ":~")
  else
    return vim.api.nvim_buf_get_name(bufnr)
  end
end

local function always()
  return true
end

oil.setup({
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
    -- Toggles a preview split to the right, keeping focus in oil
    ["<C-p>"] = { "actions.preview", opts = { split = "belowright" } },
    ["<leader>p"] = function()
      local entry = oil.get_cursor_entry()
      local dir = oil.get_current_dir()
      if not entry or not dir then
        return
      end
      oil.close()

      require("img-clip").paste_image({}, dir .. entry.name)
    end,
    ["<C-l>"] = false,
    ["<C-w>"] = false,
    ["<C-h>"] = false,
    ["h"] = "actions.parent",
    ["l"] = "actions.select",
  },
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    case_insensitive = true,
  },
  float = {
    preview_split = "right",
  },
  -- Keep git in sync when moving or deleting tracked files. New files are left
  -- unstaged so scratch files and secrets are never added automatically.
  git = {
    mv = always,
    rm = always,
  },
})

require("oil-lsp-diagnostics").setup()
require("oil-git-status").setup()
