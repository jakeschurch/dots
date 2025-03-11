local lsp_signature = require("lsp_signature")

lsp_signature.setup({
  bind = false,
  hint_enable = true,
  hint_prefix = "",
  floating_window = false,
  floating_window_above_cur_line = false,
  always_trigger = false,
  hint_inline = function()
    return false
  end,
})

local lsp = {}
local lsp_config = require("lspconfig")

local lsp_status = require("lsp-status")
lsp_status.register_progress()

vim.lsp.set_log_level(vim.lsp.log_levels.WARN)

vim.lsp.handlers["window/showMessage"] = function(_, result)
  if result.type == 1 then -- Error message
    vim.notify(result.message, vim.log.levels.ERROR)
  end
end

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
  vim.lsp.buf.format()
end, {})

local wk = require("which-key")
wk.add({
  { "<leader>K", "Hover doc" },
  { "<leader>gd", "Go to definition" },
  { "<leader>gi", "Go to implementation" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf

    local opts = { buffer = bufnr, noremap = true, silent = true }

    vim.keymap.set("i", "<C-k>", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "gk", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("i", "<C-L>", vim.lsp.buf.signature_help, opts)

    vim.keymap.set("n", "<leader>f", function()
      vim.lsp.buf.format()
    end, { buffer = bufnr })

    local function safe_lspsaga(cmd)
      return function()
        vim.cmd(cmd)
      end
    end

    vim.keymap.set("n", "gd", safe_lspsaga("Lspsaga goto_definition"), opts)
    vim.keymap.set(
      "n",
      "gy",
      safe_lspsaga("Lspsaga goto_type_definition"),
      opts
    )
    vim.keymap.set("n", "gr", safe_lspsaga("Lspsaga finder"), opts)
    vim.keymap.set("n", "K", safe_lspsaga("Lspsaga hover_doc"), opts)
    vim.keymap.set("n", "gp", safe_lspsaga("Lspsaga peek_definition"), opts)
    vim.keymap.set("n", "<leader>rn", safe_lspsaga("Lspsaga rename"), opts)

    -- Diagnostic navigation
    vim.keymap.set("n", "[d", function()
      require("lspsaga.diagnostic").goto_prev({
        severity = vim.diagnostic.severity.ERROR,
      })
    end, opts)

    vim.keymap.set("n", "]d", function()
      require("lspsaga.diagnostic").goto_next({
        severity = vim.diagnostic.severity.ERROR,
      })
    end, opts)

    vim.keymap.set(
      "n",
      "[g",
      safe_lspsaga("Lspsaga diagnostic_jump_prev"),
      opts
    )
    vim.keymap.set(
      "n",
      "]g",
      safe_lspsaga("Lspsaga diagnostic_jump_next"),
      opts
    )

    -- Call hierarchy
    vim.keymap.set(
      "n",
      "<Leader>hc",
      safe_lspsaga("Lspsaga incoming_calls"),
      opts
    )
    vim.keymap.set(
      "n",
      "<Leader>ho",
      safe_lspsaga("Lspsaga outgoing_calls"),
      opts
    )

    -- Code actions
    vim.keymap.set(
      { "n", "v" },
      "<leader>qf",
      safe_lspsaga("Lspsaga code_action"),
      opts
    )
  end,
})

for server, config in pairs(require("plugin.lsp_servers")) do
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local merged_capabilities = vim.tbl_deep_extend(
    "force",
    {},
    require("cmp_nvim_lsp").default_capabilities(capabilities),
    -- File watching is disabled by default for neovim.
    -- See: https://github.com/neovim/neovim/pull/22405
    { workspace = { didChangeWatchedFiles = { dynamicRegistration = true } } }
  )

  config.capabilities = merged_capabilities

  config["root_dir"] = config["root_dir"]
    or function(fname)
      local util = require("lspconfig.util")
      return util.root_pattern(".git")(fname) or nil
    end

  lsp_config[server].setup(config)
end
