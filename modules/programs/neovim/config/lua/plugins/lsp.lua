local lsp = {}
local lsp_config = require("lspconfig")
local virtualtypes = require("virtualtypes")

local lsp_status = require("lsp-status")
lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.INFO)

local common_capabilities = vim.tbl_extend(
  "force",
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities(),
  lsp_status.capabilities,
  { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
)

lsp.util = { default_config = {} }
lsp.util.default_config = vim.tbl_extend("force", lsp.util.default_config, {
  on_attach = function(client)
    -- Enable code action capabilities
    client.server_capabilities.codeActionProvider = true
    client.server_capabilities.semanticTokensProvider = nil
    -- Enable some LSP features if necessary
    client.server_capabilities.completionProvider = true
    -- Enable auto-import and completion features, if supported
    client.server_capabilities.textDocument.completion.completionItem.resolveSupport =
      {
        properties = { "documentation", "detail", "additionalTextEdits" },
      }
  end,
})

local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    float = true,
    severity_sort = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = true,
  })

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    -- filter = function(client)
    --   return client.name == "null-ls"
    -- end,
    timeout_ms = 5000,
    bufnr = bufnr,
  })
end

-- if you want to set up formatting on save, you can use this as a callback
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

function lsp.common_on_attach(client, bufnr)
  vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"

  local opts = { buffer = bufnr, noremap = true, silent = true }

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

  vim.keymap.set("n", "<space>f", function()
    vim.lsp.buf.format({ async = true })
  end, opts)

  -- if client.supports_method("textDocument/codeLens") then
  -- virtualtypes.on_attach(client, bufnr)
  -- end

  lsp_status.on_attach(client, bufnr)

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end

for server, config in pairs(require("plugins.lsp_servers")) do
  config.on_attach = lsp.common_on_attach
  config.capabilities = common_capabilities
  config.capabilities.offsetEncoding = { "utf-16" }
  lsp_config[server].setup(config)
end

return lsp
