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

local lsp_status = require("lsp-status")
lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.lsp.handlers["window/showMessage"] = function(_, result)
  if result.type == 1 then -- Error message
    vim.notify(result.message, vim.log.levels.ERROR)
  end
end

vim.diagnostic.config({
  virtual_text = true,      -- Enable virtual text for diagnostics
  underline = true,         -- Underline the text with diagnostics
  update_in_insert = false, -- Don't update diagnostics in insert mode
  severity_sort = true,     -- Sort diagnostics by severity
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
vim.api.nvim_create_user_command("Format", vim.lsp.buf.format, {})
vim.o.omnifunc = "v:lua.vim.lsp.omnifunc"

local wk = require("which-key")
wk.register({
  ["gd"] = "Go to definition",
  ["gi"] = "Go to implementation",
  ["K"] = "Hover doc",
  -- other keymaps
}, { prefix = "<leader>" })

local custom_on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }

  -- Not having this caused me so much pain lol
  client.server_capabilities.semanticTokensProvider = nil

  -- Ensure LSP supports codeLens before attaching virtualtypes
  if client.server_capabilities.codeLensProvider then
    pcall(virtualtypes.on_attach, client, bufnr)
  end

  -- Ensure signature help is attached safely
  if client.server_capabilities.signatureHelpProvider then
    pcall(lsp_signature.on_attach, lsp_signature_config, bufnr)
  end

  vim.keymap.set("i", "<C-k>", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("i", "<C-L>", vim.lsp.buf.signature_help, opts)
  vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)

  local function safe_lspsaga(cmd)
    return function()
      local clients = vim.lsp.get_clients({ bufnr = bufnr })
      if clients and #clients > 0 then
        vim.cmd(cmd)
      else
        vim.notify("No LSP client attached", vim.log.levels.WARN)
      end
    end
  end

  vim.keymap.set("n", "gd", safe_lspsaga("Lspsaga goto_definition"), opts)
  vim.keymap.set("n", "gy", safe_lspsaga("Lspsaga goto_type_definition"), opts)
  vim.keymap.set("n", "gr", safe_lspsaga("Lspsaga finder"), opts)
  vim.keymap.set("n", "K", safe_lspsaga("Lspsaga hover_doc"), opts)
  vim.keymap.set("n", "gp", safe_lspsaga("Lspsaga peek_definition"), opts)
  vim.keymap.set("n", "<leader>rn", safe_lspsaga("Lspsaga rename"), opts)

  -- Diagnostic navigation
  vim.keymap.set("n", "[d", function()
    require("lspsaga.diagnostic").goto_prev({ severity = vim.diagnostic.severity.ERROR })
  end, opts)

  vim.keymap.set("n", "]d", function()
    require("lspsaga.diagnostic").goto_next({ severity = vim.diagnostic.severity.ERROR })
  end, opts)

  vim.keymap.set("n", "[g", safe_lspsaga("Lspsaga diagnostic_jump_prev"), opts)
  vim.keymap.set("n", "]g", safe_lspsaga("Lspsaga diagnostic_jump_next"), opts)

  -- Call hierarchy
  vim.keymap.set("n", "<Leader>hc", safe_lspsaga("Lspsaga incoming_calls"), opts)
  vim.keymap.set("n", "<Leader>ho", safe_lspsaga("Lspsaga outgoing_calls"), opts)

  -- Code actions
  vim.keymap.set("n", "<leader>qf", safe_lspsaga("Lspsaga code_action"), opts)
  vim.keymap.set("v", "<leader>qf", safe_lspsaga("Lspsaga code_action"), opts)
end

for server, config in pairs(require("plugin.lsp_servers")) do
  config.capabilities = vim.tbl_deep_extend(
    "force",
    vim.lsp.protocol.make_client_capabilities(),
    require("cmp_nvim_lsp").default_capabilities(),
    config.capabilities or {}
  )

  config["root_dir"] = config["root_dir"]
      or function(fname)
        local util = require("lspconfig.util")
        return util.root_pattern(".git")(fname) or nil
      end

  config.on_attach = custom_on_attach

  lsp_config[server].setup(config)
end


return lsp
