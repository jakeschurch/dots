local hop = require("hop")
hop.setup()

local which_key = require("which-key")

-- Map `s` and `S` directly in normal mode using `vim.keymap.set`
vim.keymap.set(
  "n",
  "s",
  hop.hint_char2,
  { silent = true, noremap = true, desc = "Hop 2-Char Pattern" }
)
vim.keymap.set(
  "n",
  "S",
  hop.hint_char2,
  { silent = true, noremap = true, desc = "Hop 2-Char Pattern" }
)

-- Optional: Register with `which-key` to display in the popup
which_key.add({
  { "s", hop.hint_char2, desc = "Hop 2-Char Pattern" },
  { "S", hop.hint_char2, desc = "Hop 2-Char Pattern" },
}, {
  mode = "n", -- Specify the mode (normal mode)
  prefix = "", -- No prefix since these are direct mappings
})
