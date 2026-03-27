local img_clip = require("img-clip")

-- Helper to get git root
local function get_git_root()
  return vim.fs.root(0, ".git") or vim.uv.cwd()
end

img_clip.setup({
  default = {
    dir_path = function()
      return get_git_root() .. "/images"
    end,
    relative_to_current_file = false,
  },
})

vim.keymap.set(
  "n",
  "<leader>p",
  "<cmd>PasteImage<CR>",
  { noremap = true, silent = true }
)
