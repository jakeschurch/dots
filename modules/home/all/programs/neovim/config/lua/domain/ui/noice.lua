require("noice").setup({
  cmdline = {
    enabled = true,
    view = "cmdline",
    format = {
      search_down = {
        view = "cmdline",
      },
      search_up = {
        view = "cmdline",
      },
      filter = { pattern = "^:%s*!", icon = "$", ft = "sh" },
      substitute = {
        pattern = "^:%%?s/",
        icon = "󰏘 ",
        ft = "regex",
        opts = { border = { text = { top = " sub (old/new/) " } } },
      },
    },
  },
  messages = { enabled = true },
  popupmenu = { enabled = true },
  notify = { enabled = true },
  commands = {
    history = {},
  },
  lsp = {
    hover = { enabled = true },
    signature = { enabled = true },
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30,
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  presets = {
    bottom_search = true,
    command_palette = false,
    long_message_to_split = true,
    inc_rename = false,
    lsp_doc_border = false,
  },
  routes = {
    {
      filter = { event = "msg_show", find = "written" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "yanked" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "%d+L, %d+B" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "; after #%d+" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "; before #%d+" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "%d fewer lines" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "%d more lines" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "<ed" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = ">ed" },
      opts = { skip = true },
    },
    {
      filter = { event = "msg_show", find = "Hop" },
      opts = { skip = true },
    },
    {
      filter = { event = "lsp", kind = "progress" },
      view = "mini",
    },
    {
      filter = {
        event = "lsp",
        kind = "progress",
        cond = function(msg)
          local client = vim.tbl_get(msg.opts, "progress", "client")
          return client == "rust-analyzer" or client == "gopls"
        end,
      },
      opts = { skip = true },
    },
  },
})
