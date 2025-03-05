vim.g.LspTimeoutConfig = {
  stopTimeout = 1000 * 60 * 5,   -- ms, timeout before stopping all LSP servers
  startTimeout = 1000 * 10,      -- ms, timeout before restart
  silent = true,
}
