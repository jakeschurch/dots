local lsp_status = require("lsp-status")
lsp_status.register_progress()

vim.lsp.log.set_level("warn")

vim.diagnostic.config({
  virtual_text = false,
  underline = true, -- Underline the text with diagnostics
  update_in_insert = false, -- Don't update diagnostics in insert mode
  severity_sort = true, -- Sort diagnostics by severity
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded", -- Rounded border for floating windows
  },
  signs = {
    severity = {
      [vim.diagnostic.severity.ERROR] = { text = " " },
      [vim.diagnostic.severity.WARN] = { text = " " },
      [vim.diagnostic.severity.INFO] = { text = " " },
      [vim.diagnostic.severity.HINT] = { text = " " },
    },
  },
})

-- make a new command for formatting the buffer
vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format()
end, {})

-- Inlay hints toggle (global, not per-buffer)
vim.keymap.set("n", "<leader>l", function()
  local enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not enabled)
  print("Inlay hints " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle Inlay Hints" })

local function diagnostic_jump_next(severity)
  if #require("lspsaga.diagnostic"):get_diagnostic({ buffer = true }) == 0 then
    return
  end
  if severity then
    require("lspsaga.diagnostic"):diagnostic_jump_next({ severity = severity })
  else
    vim.cmd("Lspsaga diagnostic_jump_next")
  end
end

local function diagnostic_jump_prev(severity)
  if #require("lspsaga.diagnostic"):get_diagnostic({ buffer = true }) == 0 then
    return
  end
  if severity then
    require("lspsaga.diagnostic"):diagnostic_jump_prev({ severity = severity })
  else
    vim.cmd("Lspsaga diagnostic_jump_prev")
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    local function buf_map(mode, lhs, rhs, desc)
      vim.keymap.set(
        mode,
        lhs,
        rhs,
        { buffer = bufnr, noremap = true, silent = true, desc = desc }
      )
    end

    buf_map("i", "<C-k>", vim.lsp.buf.hover, "Hover (insert)")
    buf_map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    buf_map("n", "gk", vim.lsp.buf.signature_help, "Signature help")
    buf_map("n", "<leader>f", vim.lsp.buf.format, "Format buffer")

    buf_map(
      "n",
      "gy",
      "<cmd>Lspsaga goto_type_definition<cr>",
      "Go to type definition"
    )
    buf_map("n", "gd", "<cmd>Lspsaga goto_definition<cr>", "Go to definition")
    buf_map("n", "gr", "<cmd>Lspsaga finder<cr>", "Find references")
    buf_map("n", "gp", "<cmd>Lspsaga peek_definition<cr>", "Peek definition")
    buf_map("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", "Rename symbol")

    -- Diagnostic navigation
    buf_map("n", "[d", function()
      diagnostic_jump_prev(vim.diagnostic.severity.ERROR)
    end, "Prev error")
    buf_map("n", "]d", function()
      diagnostic_jump_next(vim.diagnostic.severity.ERROR)
    end, "Next error")
    buf_map("n", "[g", diagnostic_jump_prev, "Prev diagnostic")
    buf_map("n", "]g", diagnostic_jump_next, "Next diagnostic")

    -- Call hierarchy
    buf_map(
      "n",
      "<Leader>gc",
      "<cmd>Lspsaga incoming_calls<cr>",
      "Incoming calls"
    )
    buf_map(
      "n",
      "<Leader>go",
      "<cmd>Lspsaga outgoing_calls<cr>",
      "Outgoing calls"
    )

    -- Code actions
    buf_map(
      { "n", "v" },
      "<leader>qf",
      "<cmd>Lspsaga code_action<cr>",
      "Code action"
    )
  end,
})

local blink_cmp = require("blink.cmp")

-- Default root_dir function using git
local function default_root_dir(bufnr, on_dir)
  local root = vim.fs.root(bufnr, { ".git" })
  if root then
    on_dir(root)
  end
end

for server, config in pairs(require("plugin.lsp_servers")) do
  config.capabilities = vim.tbl_deep_extend(
    "force",
    config.capabilities or {},
    -- File watching is disabled by default for neovim.
    -- See: https://github.com/neovim/neovim/pull/22405
    { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
    blink_cmp.get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())
  )

  config["root_dir"] = config["root_dir"] or default_root_dir

  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
