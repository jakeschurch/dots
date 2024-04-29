let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
if ! empty(b:undo_ftplugin)
  let b:undo_ftplugin .= ' | '
endif
let b:undo_ftplugin .= 'setlocal nowrap< linebreak< nolist< tw< wrapmargin< colorcolumn<'

setlocal nowrap
setlocal linebreak
setlocal nolist
setlocal tw=0
setlocal wrapmargin=0
setlocal colorcolumn=0
setlocal ts=2 sts=2 sw=2
setlocal textwidth=80
set spell

autocmd Filetype vimwiki noremap <buffer> <leader>l :VimwikiToggleListItem<cr>
autocmd Filetype vimwiki vmap <buffer> <leader>l :VimwikiToggleListItem<cr>
