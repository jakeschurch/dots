local img_clip = require("img-clip")

require("image").setup({})

-- Helper to get git root
local function get_git_root()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local result = handle:read("*l")
    handle:close()
    if result then
      return result
    end
  end
  return vim.loop.cwd() -- fallback to current working dir
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
  "<cmd>PasteImg<CR>",
  { noremap = true, silent = true }
)
