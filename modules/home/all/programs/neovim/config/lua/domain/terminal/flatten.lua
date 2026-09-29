-- nvim launched from a :terminal (Claude's ctrl+g, `git commit` in toggleterm)
-- opens its files in this instance instead of nesting. Must load eagerly: the
-- guest side hooks the first BufEnter during startup.
--
-- Blocking (guest waits until the buffer is closed) happens for gitcommit /
-- gitrebase via flatten's default `block_for`, and for anything spawned from
-- the sidekick CLI, which sets SIDEKICK_EDITOR_BLOCK (see ai/sidekick.lua) so
-- Claude's markdown prompt file waits too.

-- Window that launched the guest, refocused once a blocking edit is done.
local origin

require("flatten").setup({
  window = {
    -- Split below the launching window. Floats (toggleterm) can't be split,
    -- so hide the float and split the window underneath instead.
    open = function(ctx)
      local file = ctx.stdin_buf or ctx.files[1]
      origin = vim.api.nvim_get_current_win()

      if vim.api.nvim_win_get_config(origin).relative ~= "" then
        vim.api.nvim_win_hide(origin)
        origin = nil
      end

      local win = vim.api.nvim_open_win(file.bufnr, true, {
        vertical = false,
        win = 0,
      })
      return file.bufnr, win
    end,
  },
  hooks = {
    should_block = function(argv)
      return vim.env.SIDEKICK_EDITOR_BLOCK == "1"
        or vim.tbl_contains(argv, "-b")
    end,
    block_end = function()
      vim.schedule(function()
        if origin and vim.api.nvim_win_is_valid(origin) then
          vim.api.nvim_set_current_win(origin)
          if vim.bo[vim.api.nvim_win_get_buf(origin)].buftype == "terminal" then
            vim.cmd.startinsert()
          end
        end
        origin = nil
      end)
    end,
  },
})
