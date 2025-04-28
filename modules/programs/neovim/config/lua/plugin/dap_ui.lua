local dapui = require("dapui")
local dap = require("dap")

vim.cmd([[
cnoreabbrev dapclose lua require'dapui'.close()<cr>
cnoreabbrev dapopen lua require'dapui'.open()<cr>
]])

vim.keymap.set({ "n", "v" }, "<c-b>", function()
  dapui.eval()
end)

dapui.setup({
  icons = { expanded = "▾", collapsed = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
  },
  layouts = {
    {
      elements = {
        {
          id = "breakpoints",
          size = 0.1,
        },
        {
          id = "watches",
          size = 0.9,
        },
      },
      position = "top",
      size = 15,
    },
    {
      elements = {
        {
          id = "console",
          size = 0.7,
        },
        {
          id = "repl",
          size = 0.3,
        },
      },
      position = "bottom",
      size = 10,
    },
  },
  windows = { indent = 1 },
})

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
