vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

require("oil").setup({
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
