require("ghlite").setup({
  debug = false, -- if set to true debugging information is written to ~/.ghlite.log file
  view_split = "", -- set to empty string '' to open in active buffer
  diff_split = "vsplit", -- set to empty string '' to open in active buffer
  comment_split = "split", -- set to empty string '' to open in active buffer
  open_command = "open", -- open command to use, e.g. on Linux you might want to use xdg-open
})

local keys = {
  { "<leader>uo", ":GHLitePRCheckout<cr>", { silent = true } },
  { "<leader>uv", ":GHLitePRView<cr>", { silent = true } },
  { "<leader>uu", ":GHLitePRLoadComments<cr>", { silent = true } },
  { "<leader>up", ":GHLitePRDiff<cr>", { silent = true } },
  { "<leader>ua", ":GHLitePRAddComment<cr>", { silent = true } },
  { "<leader>ug", ":GHLitePROpenComment<cr>", { silent = true } },
}

-- Iterate over the keys table and set each mapping
for _, keymap in ipairs(keys) do
  local key_combination, command, options = unpack(keymap)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.keymap.set("n", key_combination, command, options)
end
