vim.lsp.log.set_level("warn")

vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = true,
    style = "minimal",
    border = "rounded",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󱍷 ",
      [vim.diagnostic.severity.WARN] = "󰀪 ",
      [vim.diagnostic.severity.INFO] = "󰋽 ",
      [vim.diagnostic.severity.HINT] = "󰌶 ",
    },
  },
})

vim.api.nvim_create_user_command("Format", function()
  vim.lsp.buf.format()
end, {})

vim.keymap.set("n", "<leader>l", function()
  local enabled = vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(not enabled)
  print("Inlay hints " .. (enabled and "disabled" or "enabled"))
end, { desc = "Toggle Inlay Hints" })

local function diagnostic_jump_next(severity)
  vim.diagnostic.jump({ count = 1, severity = severity, buffer = 0 })
  vim.cmd("Lspsaga code_action")
end

local function diagnostic_jump_prev(severity)
  vim.diagnostic.jump({ count = -1, severity = severity, buffer = 0 })
  vim.cmd("Lspsaga code_action")
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

    buf_map(
      { "n", "v" },
      "<leader>ca",
      "<cmd>Lspsaga code_action<cr>",
      "Code action"
    )
  end,
})

vim.lsp.config("*", {
  capabilities = vim.tbl_deep_extend(
    "force",
    { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } },
    require("blink.cmp").get_lsp_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    )
  ),
  root_markers = { ".git" },
})

for server, config in pairs(require("plugin.lsp_servers")) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end
