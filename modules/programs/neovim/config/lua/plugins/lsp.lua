local lsp = {}
local lsp_config = require("lspconfig")
local virtualtypes = require("virtualtypes")
local lsp_status = require("lsp-status")

lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.INFO)

local lspconfig_defaults = lsp_config.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults,
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities(),
  lsp_status.capabilities,
  lspconfig_defaults.capabilities
)

vim.diagnostic.config({
  virtual_text = true, -- Enable virtual text for diagnostics
  underline = true, -- Underline the text with diagnostics
  update_in_insert = false, -- Don't update diagnostics in insert mode
  severity_sort = true, -- Sort diagnostics by severity
  float = {
    show_header = true, -- Show a header in the floating window
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
  vim.lsp.buf.format({ async = true })
end, {})

-- local format_on_save_autocmd_id = nil
--
-- function ToggleFormatOnSave()
--   if format_on_save_autocmd_id then
--     -- Remove the autocmd if it exists
--     vim.api.nvim_del_autocmd(format_on_save_autocmd_id)
--     format_on_save_autocmd_id = nil
--     print("Format on save disabled")
--   else
--     -- Create the autocmd if it doesn't exist
--     format_on_save_autocmd_id = vim.api.nvim_create_autocmd("BufWritePre", {
--       desc = "Format on save",
--       callback = function()
--         vim.lsp.buf.format({ async = true })
--       end,
--     })
--     print("Format on save enabled")
--   end
-- end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.buf, noremap = true, silent = true }

    vim.keymap.set(
      { "i" },
      "<C-k>",
      vim.lsp.buf.hover,
      { silent = true, noremap = true, desc = "toggle signature" }
    )
    vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gy", "<cmd>Lspsaga goto_type_definition<CR>", opts)

    vim.keymap.set("n", "<leader>o", "<Cmd>Lspsaga outline<cr>", opts)
    vim.keymap.set("n", "gr", "<Cmd>Lspsaga finder<cr>", opts)

    vim.keymap.set("n", "gh", "<cmd>Lspsaga finder<CR>", opts)

    vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", opts)
    vim.keymap.set("i", "<C-L>", "<cmd>Lspsaga signature_help<cr>", opts)

    vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<cr>", opts)
    vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

function lsp.common_on_attach(client, bufnr)
  vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"

  if client.server_capabilities.semanticTokensProvider then
    client.server_capabilities.semanticTokensProvider = nil
  end

  if client.supports_method("textDocument/codeLens") then
    virtualtypes.on_attach(client, bufnr)
  end

  lsp_status.on_attach(client, bufnr)
end

for server, config in pairs(require("plugins.lsp_servers")) do
  -- Save the existing on_attach function if it exists
  local custom_on_attach = config.on_attach

  -- Wrap the custom on_attach with common_on_attach
  config.on_attach = function(client, bufnr)
    lsp.common_on_attach(client, bufnr)

    client.offset_encoding = "utf-16"
    config.capabilities = lspconfig_defaults.capabilities
    config.capabilities.offsetEncoding = { "utf-16" }

    -- Call the custom on_attach if provided
    if custom_on_attach then
      custom_on_attach(client, bufnr)
    end
  end

  lsp_config[server].setup(config)
end

return lsp
