let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
if ! empty(b:undo_ftplugin)
  let b:undo_ftplugin .= ' | '
endif
let b:undo_ftplugin .= 'setlocal nowrap< linebreak< nolist< tw< wrapmargin< colorcolumn<'

setlocal wrap
setlocal linebreak
setlocal nolist
setlocal tw=0
setlocal wrapmargin=0
setlocal colorcolumn=0
setlocal ts=2 sts=2 sw=2
setlocal textwidth=80
setlocal spell
setlocal formatoptions = "tqclnjaw"

noremap <buffer> <leader>l :VimwikiToggleListItem<cr>
vmap <buffer> <leader>l :VimwikiToggleListItem<cr>

let g:limelight_priority = -1
let g:limelight_paragraph_span = 3

lua <<EOF
local goyo_group = vim.api.nvim_create_augroup("GoyoGroup", { clear = true })
vim.api.nvim_create_autocmd("User", {
    desc = "Hide lualine on goyo enter",
    group = goyo_group,
    pattern = "GoyoEnter",
    callback = function()
        require("lualine").hide()
        vim.cmd[[Limelight]]
    end,
})
vim.api.nvim_create_autocmd("User", {
    desc = "Show lualine after goyo exit",
    group = goyo_group,
    pattern = "GoyoLeave",
    callback = function()
        require("lualine").hide({ unhide = true })
        vim.cmd[[Limelight!]]
    end,
})
EOF
