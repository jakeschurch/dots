local img_clip = require("img-clip")

img_clip.setup({
  default = {
    relative_to_current_file = true,
  },
})

vim.keymap.set(
  "n",
  "<leader>p",
  img_clip.paste_image,
  { noremap = true, silent = true }
)
