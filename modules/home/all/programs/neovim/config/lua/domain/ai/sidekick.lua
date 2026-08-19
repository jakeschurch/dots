-- Claude Code in a split, with buffer/selection/diagnostic context sent from
-- Neovim. `cli.watch` reloads buffers the CLI edits underneath us.
--
-- NES (next edit suggestions) is off: it needs the proprietary copilot LSP and
-- overlaps with the blink-copilot completion source already in use. Flip
-- `nes.enabled` and add copilot-language-server to dev-packages to try it.

require("sidekick").setup({
  nes = { enabled = false },
  cli = {
    watch = true,
    win = { layout = "right", split = { width = 90 } },
    picker = "fzf-lua",
  },
})

local cli = require("sidekick.cli")

local function claude(fn, opts)
  return function()
    fn(vim.tbl_extend("force", { name = "claude", focus = true }, opts or {}))
  end
end

require("which-key").add({
  { "<leader>a", group = "ai" },

  { "<leader>aa", claude(cli.toggle), desc = "Toggle Claude Code" },
  { "<leader>ah", claude(cli.hide), desc = "Hide Claude Code" },
  { "<leader>at", cli.select, desc = "Pick a CLI tool" },

  {
    "<leader>as",
    claude(cli.send, { msg = "{this}" }),
    desc = "Send this",
    mode = { "n", "x" },
  },
  {
    "<leader>af",
    claude(cli.send, { msg = "{file}" }),
    desc = "Send file",
  },
  {
    "<leader>ap",
    claude(cli.prompt),
    desc = "Prompt library",
    mode = { "n", "x" },
  },
  {
    "<leader>ad",
    claude(cli.send, { prompt = "diagnostics" }),
    desc = "Send diagnostics",
  },
  {
    "<leader>ar",
    claude(cli.send, { prompt = "review" }),
    desc = "Review file",
  },
  {
    "<leader>ac",
    claude(cli.send, { prompt = "changes" }),
    desc = "Review changes",
  },
})
