local snacks = require("snacks")

snacks.setup({
  bigfile = {},
  bufdelete = {},
  quickfile = {},
})

require("which-key").add({
  { "<leader>bd", snacks.bufdelete.delete, desc = "Delete this buffer" },
  { "<leader>ba", snacks.bufdelete.all, desc = "Delete all buffers" },
  { "<leader>bo", snacks.bufdelete.other, desc = "Delete other buffers" },
})
