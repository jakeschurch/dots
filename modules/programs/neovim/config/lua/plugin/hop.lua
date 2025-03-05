local hop = require("hop")
hop.setup()

local which_key = require("which-key")

-- Use functions to wrap `hop.hint_char2`
local function hop_char2()
  hop.hint_char2()
end

-- Map `s` and `S` directly in normal mode
vim.keymap.set("n", "s", hop_char2, { silent = true, noremap = true, desc = "Hop 2-Char Pattern" })
vim.keymap.set("n", "S", hop_char2, { silent = true, noremap = true, desc = "Hop 2-Char Pattern" })

-- Optional: Register with `which-key` (not required for functionality)
which_key.add({
  s = { hop_char2, "Hop 2-Char Pattern" },
  S = { hop_char2, "Hop 2-Char Pattern" },
})
