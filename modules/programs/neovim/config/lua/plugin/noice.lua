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
      -- execute shell command (!command)
      filter = { pattern = "^:%s*!", icon = "$", ft = "sh" },
      substitute = {
        pattern = "^:%%?s/",
        icon = " ",
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
    hover = { enabled = false },
    signature = { enabled = false },
  },
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = false, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  routes = {
    { filter = { event = "msg_show", find = "written" } },
    { filter = { event = "msg_show", find = "yanked" } },
    { filter = { event = "msg_show", find = "%d+L, %d+B" } },
    { filter = { event = "msg_show", find = "; after #%d+" } },
    { filter = { event = "msg_show", find = "; before #%d+" } },
    { filter = { event = "msg_show", find = "%d fewer lines" } },
    { filter = { event = "msg_show", find = "%d more lines" } },
    { filter = { event = "msg_show", find = "<ed" } },
    { filter = { event = "msg_show", find = ">ed" } },
    { filter = { event = "msg_show", find = "Hop" } },
  },
})
