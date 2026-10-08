require("gitsigns").setup({
  -- Use Neovim's built-in differ rather than shelling out to `git diff`.
  -- Without this, gitsigns inherits the global `diff.external =
  -- difftastic-inline`, whose output has no unified-diff hunk headers, so every
  -- buffer reports zero hunks and no signs appear.
  diff_opts = { internal = true },

  -- Block elements rather than Nerd Font glyphs: plain BMP codepoints, so they
  -- render without a patched font and cannot fall back to an emoji font.
  -- Staged hunks use a thinner bar than unstaged ones.
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    changedelete = { text = "▎" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
    untracked = { text = "▏" },
  },
  signs_staged = {
    add = { text = "▏" },
    change = { text = "▏" },
    changedelete = { text = "▏" },
    delete = { text = "▁" },
    topdelete = { text = "▔" },
  },

  current_line_blame_opts = {
    delay = 100,
    ignore_whitespace = true,
  },
  current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
  max_file_length = 4000, -- Disable if file is longer than this (in lines)
  preview_config = {
    -- Options passed to nvim_open_win
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 0,
    col = 1,
  },

  on_attach = function(bufnr)
    local gitsigns = require("gitsigns")

    local function map(mode, l, r, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, l, r, opts)
    end

    -- Navigation
    map("n", "]c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "]c", bang = true })
      else
        gitsigns.nav_hunk("next")
      end
    end, { desc = "Next hunk" })

    map("n", "[c", function()
      if vim.wo.diff then
        vim.cmd.normal({ "[c", bang = true })
      else
        gitsigns.nav_hunk("prev")
      end
    end, { desc = "Prev hunk" })

    -- Actions
    map(
      { "n", "v" },
      "<leader>hs",
      ":Gitsigns stage_hunk<CR>",
      { desc = "Stage/unstage hunk" }
    )
    map(
      { "n", "v" },
      "<leader>hr",
      ":Gitsigns reset_hunk<CR>",
      { desc = "Reset hunk" }
    )
    map("n", "<leader>hS", gitsigns.stage_buffer, { desc = "Stage buffer" })
    map("n", "<leader>hR", gitsigns.reset_buffer, { desc = "Reset buffer" })
    map("n", "<leader>hp", gitsigns.preview_hunk, { desc = "Preview hunk" })
    map("n", "<leader>hQ", function()
      gitsigns.setqflist("all")
    end, { desc = "All hunks to quickfix" })
    map(
      "n",
      "<leader>hq",
      gitsigns.setqflist,
      { desc = "Buffer hunks to quickfix" }
    )
    map("n", "<leader>hb", function()
      gitsigns.blame_line({ full = true })
    end, { desc = "Blame line" })
    map(
      "n",
      "<leader>tb",
      gitsigns.toggle_current_line_blame,
      { desc = "Toggle line blame" }
    )
    map("n", "<leader>hd", gitsigns.diffthis, { desc = "Diff against index" })
    map("n", "<leader>hD", function()
      gitsigns.diffthis("~")
    end, { desc = "Diff against last commit" })
    map(
      "n",
      "<leader>td",
      gitsigns.preview_hunk_inline,
      { desc = "Preview hunk inline" }
    )

    -- text objects
    map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Hunk" })
  end,
})
