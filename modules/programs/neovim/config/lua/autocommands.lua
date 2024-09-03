vim.cmd([[

augroup _general_settings
autocmd!
autocmd FileType qf,help,man,lspinfo nnoremap <silent> <buffer> q :close<CR>
autocmd TextYankPost * silent! lua vim.highlight.on_yank{on_visual = true}
augroup END

augroup _git
autocmd!
autocmd FileType gitcommit setlocal wrap
autocmd FileType gitcommit setlocal spell
augroup END

hi myTodo cterm=bold,italic gui=bold,italic guibg=#32302f guifg=#fabd2f

" trim new lines
autocmd BufWritePre * silent! :%s/\s\+$//e

augroup HiglightTODO
autocmd!
autocmd WinEnter,VimEnter * :silent!
\ call matchadd('myTodo', '\%\(TODO\|FIXME\|OPTIMIZE\|XXX\)[Ss:]\?', 10)
augroup END

augroup HiglightDebug
autocmd!
autocmd WinEnter,VimEnter * :silent!
\ call matchadd('Question', '\%\(BUG\|NOTE\|IDEA\|INFO\|TEMP\|REVIEW\|DONE\)[Ss:]\?', 10)
augroup END

]])

vim.api.nvim_create_autocmd({ "BufReadPost" }, {
  pattern = { "*" },
  callback = function()
    local ft = vim.opt_local.filetype:get()
    -- don't apply to git messages
    if ft:match("commit") or ft:match("rebase") then
      return
    end
    -- get position of last saved edit
    local markpos = vim.api.nvim_buf_get_mark(0, '"')
    local line = markpos[1]
    local col = markpos[2]
    -- if in range, go there
    if (line > 1) and (line <= vim.api.nvim_buf_line_count(0)) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end,
})

local function scandir(directory)
  local i, t, popen = 0, {}, io.popen
  local pfile = popen('ls -a "' .. directory .. '"')
  for filename in pfile:lines() do
    i = i + 1
    t[i] = filename
  end
  pfile:close()
  return t
end

local HOME_DIR = os.getenv("HOME") or "~"
local TEMPLATE_DIR = HOME_DIR .. "/Documents/Templates"

local function get_templates()
  local templates = {}

  for _, value in pairs(scandir(TEMPLATE_DIR)) do
    local test = string.gsub(value, "template.(%w+)", "%1")
    if test ~= value then
      table.insert(templates, test)
    end
  end

  return templates
end

local function toSet(list)
  local set = {}
  for _, l in ipairs(list) do
    set[l] = true
  end
  return set
end

local TEMPLATE_SET = toSet(get_templates())

local function getsuffix(filename)
  return string.gsub(filename, ".*%.(%w+)", "%1")
end

-- REVIEW: nvim_create_autocmd docs can be fixed!
local group = vim.api.nvim_create_augroup("template_files", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  callback = function(ev)
    local file_suffix = getsuffix(ev["file"])

    if TEMPLATE_SET[file_suffix] then
      local template_file = TEMPLATE_DIR .. "/template." .. file_suffix
      local to_run = ":0r " .. template_file
      vim.cmd(to_run)
    end
  end,
  group = group,
})
