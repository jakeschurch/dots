local lsp_signature = require("lsp_signature")

local lsp_signature_config = {
  hint_enable = true,
  hint_prefix = "",
  floating_window = false,
  floating_window_above_cur_line = false,
  always_trigger = true,
  hint_inline = function()
    return false
  end,
}

local lsp = {}
local lsp_config = require("lspconfig")
local virtualtypes = require("virtualtypes")
-- local lsp_status = require("lsp-status")

-- lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.lsp.handlers["window/showMessage"] = function(_, result)
  if result.type == 1 then -- Error message
    vim.notify(result.message, vim.log.levels.ERROR)
  end
end

local lspconfig_defaults = lsp_config.util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "keep",
  lspconfig_defaults,
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities(),
  lspconfig_defaults.capabilities,
  -- File watching is disabled by default for neovim.
  -- See: https://github.com/neovim/neovim/pull/22405
  { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
)

lsp_config_defaults.capabilities.textDocument.completion.completionItem.snippetSupport =
  true

vim.diagnostic.config({
  virtual_text = true, -- Enable virtual text for diagnostics
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
  vim.lsp.buf.format({ async = true })
end, {})

local wk = require("which-key")
wk.register({
  ["gd"] = "Go to definition",
  ["gi"] = "Go to implementation",
  ["K"] = "Hover doc",
  -- other keymaps
}, { prefix = "<leader>" })

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
    vim.keymap.set("i", "<C-L>", function()
      vim.lsp.buf.signature_help()
    end, opts)

    vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<cr>", opts)
    vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format({ async = true })
    end, opts)
  end,
})

function lsp.common_on_attach(client, bufnr)
  vim.opt.omnifunc = "v:lua.vim.lsp.omnifunc"

  if
    client.supports_method and client:supports_method("textDocument/codeLens")
  then
    virtualtypes.on_attach(client, bufnr)
  end

  if client.server_capabilities.signatureHelpProvider then
    lsp_signature.on_attach(lsp_signature_config, bufnr)
  end

  -- lsp_status.on_attach(client, bufnr)
end

for server, config in pairs(require("plugin.lsp_servers")) do
  local custom_on_attach = config.on_attach

  config.on_attach = function(client, bufnr)
    if custom_on_attach then
      custom_on_attach(client, bufnr)
    end

    lsp.common_on_attach(client, bufnr)
  end

  config.capabilities = vim.tbl_deep_extend(
    "keep",
    lsp_config.util.default_config.capabilities or {},
    {
      offsetEncoding = config.offsetEncoding or { "utf-8" },
    }
  )

  config["root_dir"] = config["root_dir"]
    or function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern(".git")(fname) or nil
    end

  lsp_config[server].setup(config)
end

return lsp
