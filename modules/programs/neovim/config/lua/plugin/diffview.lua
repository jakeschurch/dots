require("diffview").setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  use_icons = true,
  icons = {
    folder_closed = "",
    folder_open = "",
    folder_empty = "ﰊ",
  },
  view = {
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
      winbar_info = false,
    },
  },
})

local function smart_git_diff()
  local ft = vim.bo.filetype
  if ft == "fugitive" or ft == "git" or ft == "gitcommit" then
    vim.cmd("DiffviewOpen")
  else
    -- fallback to diff current file vs HEAD
    vim.cmd("DiffviewOpen HEAD -- " .. vim.fn.expand("%:p"))
  end
end

vim.keymap.set(
  "n",
  "<leader>dv",
  smart_git_diff,
  { desc = "Smart Git Diff (Diffview or file)" }
)
