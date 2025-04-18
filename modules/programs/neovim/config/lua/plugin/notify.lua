require("notify").setup({
  render = "wrapped-compact",
  max_width = "60",
  stages = "static",
})

function Notify_output(command, opts)
  local output = ""
  local notification
  local notify = function(msg, level)
    local notify_opts = vim.tbl_extend(
      "keep",
      opts or {},
      { title = table.concat(command, " "), replace = notification }
    )

    notification = require("notify")(msg, level, notify_opts)
  end
  local on_data = function(_, data)
    output = output .. table.concat(data, "\n")
    notify(output, "info")
  end
  vim.fn.jobstart(command, {
    on_stdout = on_data,
    on_stderr = on_data,
    on_exit = function(_, code)
      if #output == 0 then
        notify("No output of command, exit code: " .. code, "warn")
      end
    end,
  })
end

-- -- REVIEW: does not work
-- function NotifyBang()
--   local cmd = vim.fn.getcmdline():sub(2)
--   local args = vim.split(cmd, " ")
--   notify_output(args)
-- end
--
-- vim.api.nvim_set_keymap(
--   "c",
--   "!",
--   "lua NotifyBang()",
--   { noremap = true, silent = true }
-- )
--
vim.cmd([[
highlight NotifyERRORBorder guifg=#8A1F1F guibg=NONE
highlight NotifyWARNBorder guifg=#79491D guibg=NONE
highlight NotifyINFOBorder guifg=#4F6752 guibg=NONE
highlight NotifyDEBUGBorder guifg=#8B8B8B guibg=NONE
highlight NotifyTRACEBorder guifg=#4F3552 guibg=NONE
highlight NotifyERRORIcon guifg=#F70067 guibg=NONE
highlight NotifyWARNIcon guifg=#F79000 guibg=NONE
highlight NotifyINFOIcon guifg=#A9FF68 guibg=NONE
highlight NotifyDEBUGIcon guifg=#8B8B8B guibg=NONE
highlight NotifyTRACEIcon guifg=#D484FF guibg=NONE
highlight NotifyERRORTitle  guifg=#F70067 guibg=NONE
highlight NotifyWARNTitle guifg=#F79000 guibg=NONE
highlight NotifyINFOTitle guifg=#A9FF68 guibg=NONE
highlight NotifyDEBUGTitle  guifg=#8B8B8B guibg=NONE
highlight NotifyTRACETitle  guifg=#D484FF guibg=NONE
highlight link NotifyERRORBody Normal
highlight link NotifyWARNBody Normal
highlight link NotifyINFOBody Normal
highlight link NotifyDEBUGBody Normal
highlight link NotifyTRACEBody Normal
]])
