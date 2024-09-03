require("gitlinker").setup({
  opts = {
    remote = nil, -- force the use of a specific remote
    -- adds current line nr in the url for normal mode
    add_current_line_on_normal_mode = true,
    -- callback for what to do with the url
    action_callback = require("gitlinker.actions").copy_to_clipboard,
    -- print the url after performing the action
    print_url = true,
  },
  callbacks = {
    ["github.com"] = require("gitlinker.hosts").get_github_type_url,
    ["gitlab.com"] = require("gitlinker.hosts").get_gitlab_type_url,
    ["try.gitea.io"] = require("gitlinker.hosts").get_gitea_type_url,
  },
})

vim.api.nvim_set_keymap(
  "n",
  "<leader>gy",
  '<cmd>lua require"gitlinker".get_buf_range_url("n", {action_callback = require("gitlinker.actions").copy_to_clipboard})<cr>',
  { silent = true }
)
vim.api.nvim_set_keymap(
  "v",
  "<leader>gy",
  '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require("gitlinker.actions").copy_to_clipboard})<cr>',
  {}
)
