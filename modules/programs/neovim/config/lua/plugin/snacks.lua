local snacks = require("snacks")

snacks.setup({
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  quickfile = { enabled = true },
  input = { enabled = true },
  scroll = { enabled = true },
})

require("which-key").add({
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete this buffer" },
  { "<leader>ba", snacks.bufdelete.all, desc = "Delete all buffers" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete other buffers" },
})
