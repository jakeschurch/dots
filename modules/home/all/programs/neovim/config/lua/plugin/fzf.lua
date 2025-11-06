local fzf_lua = require("fzf-lua")
local which_key = require("which-key")
local M = {}

local config = {
  "ivy",
  "fzf-native",
  live_grep = {
    rg_glob = true,
    glob_flag = "--iglob", -- for case sensitive globs use '--glob'
    glob_separator = "%s%-%-%s", -- query separator pattern (lua): ' --'
    hidden = true,
  },
  fzf_colors = true,
  keymap = {
    builtin = {
      ["<c-d>"] = "preview-down",
      ["<c-u>"] = "preview-up",
    },
    fzf = {
      true,
      ["ctrl-q"] = "select-all+accept", -- Send all items to qf list
    },
    ["ctrl-j"] = nil,
    ["ctrl-k"] = nil,

    ["ctrl-c"] = "abort",
    ["esc"] = "abort",

    ["ctrl-n"] = "preview-page-down",
    ["ctrl-p"] = "preview-page-up",
  },
  files = {
    prompt = nil,
    cwd_prompt_shorten_val = 3,
    cwd_prompt = true,
  },
  globals = {
    winopts = {
      preview = {
        default = "bat_native",
        border = "noborder",
        scrollbar = false,
        title = nil,
      },
    },
  },
}

fzf_lua.setup(config)

-- Helper function to get the appropriate directory for virtual buffers
local function sanitize_buf_path(bufnr)
  bufnr = bufnr or 0
  local buf_path = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

  if filetype == "oil" then
    local ok, oil = pcall(require, "oil")
    if ok and oil.get_current_dir then
      return oil.get_current_dir(bufnr)
    end
    return ""
  elseif filetype == "fugitive" then
    -- Try to get git root from buffer path
    local dir = vim.fn.fnamemodify(buf_path, ":p:h")
    local git_root =
      vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]
    if git_root and git_root ~= "" and not git_root:match("^fatal") then
      return git_root
    end
    return ""
  elseif buf_path == "" or buf_path:match("^[a-z]+://") then
    return ""
  end

  return buf_path
end

local function get_git_root_or_cwd()
  local buf_path = sanitize_buf_path(vim.api.nvim_get_current_buf())
  if buf_path == "" then
    -- No file loaded, fallback to current working directory
    return vim.fn.getcwd()
  end

  if vim.fn.isdirectory(buf_path) == 1 then
    return buf_path
  end

  local dir = vim.fn.fnamemodify(buf_path, ":p:h")
  -- Try to get git root from the buffer's directory
  local git_root =
    vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]

  if git_root and git_root ~= "" and not git_root:match("^fatal") then
    return git_root
  else
    return dir
  end
end

-- Create wrapped versions of commonly used fzf commands
local wrapped = {
  files = fzf_lua.files,
  git_files = function()
    return fzf_lua.git_files({ cwd = get_git_root_or_cwd() })
  end,
  live_grep = function()
    return fzf_lua.live_grep({ cwd = get_git_root_or_cwd() })
  end,
  grep = function()
    return fzf_lua.grep({ cwd = get_git_root_or_cwd() })
  end,
  lgrep_curbuf = fzf_lua.lgrep_curbuf,
}

-- The reason I added 'opts' as a parameter is so you can
-- call this function with your own parameters / customizations
-- for example: 'git_files_cwd_aware({ cwd = <another git repo> })'
function M.git_files_cwd_aware(opts)
  opts = opts or {}
  local path = fzf_lua.path
  -- git_root() will warn us if we're not inside a git repo
  -- so we don't have to add another warning here, if
  -- you want to avoid the error message change it to:
  -- local git_root = fzf_lua.path.git_root(opts, true)
  local git_root = path.git_root(opts)
  if not git_root then
    return
  end
  local relative = path.relative_to(vim.loop.cwd(), git_root)
  opts.fzf_opts = { ["--query"] = git_root ~= relative and relative or nil }
  return fzf_lua.git_files(opts)
end

local function recent_git_branches()
  -- Use git reflog to get unique, most recently checked-out branches
  local handle = io.popen(
    "git reflog | grep 'checkout:' | awk '{print $NF}' | awk '!seen[$0]++'"
  )
  if not handle then
    return
  end
  local result = handle:read("*a")
  handle:close()

  local branches = {}
  for branch in result:gmatch("[^\r\n]+") do
    table.insert(branches, branch)
  end

  fzf_lua.fzf_exec(branches, {
    prompt = "Recent Branches> ",
    actions = {
      ["default"] = function(selected)
        vim.cmd("Git checkout " .. selected[1])
      end,
    },
  })
end

vim.keymap.set({ "n", "v", "i" }, "<C-x><C-f>", function()
  fzf_lua.complete_path()
end, { silent = true, desc = "Fuzzy complete path" })

which_key.add({
  {
    "<leader>bb",
    fzf_lua.buffers,
    desc = "Show Buffers",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fc",
    fzf_lua.command_history,
    desc = "Command History",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fg",
    recent_git_branches,
    desc = "Git Branches",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fh",
    fzf_lua.help_tags,
    desc = "Help Tags",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fk",
    fzf_lua.keymaps,
    desc = "Keymaps",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fm",
    fzf_lua.manpages,
    desc = "Man Pages",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ja",
    fzf_lua.resume,
    desc = "Resume fzf lua search",
    nowait = true,
    remap = false,
  },
  {
    "<leader>jj",
    wrapped.live_grep,
    desc = "Grep",
    nowait = true,
    remap = false,
  },
  --- git mappings
  {
    "<leader>jk",
    wrapped.git_files,
    desc = "Git Files",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gb",
    recent_git_branches,
    desc = "Checkout Branch",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gc",
    fzf_lua.git_commits,
    desc = "Checkout Commit",
    nowait = true,
    remap = false,
  },
  {
    "<leader>go",
    fzf_lua.git_status,
    desc = "Open Changed File",
    nowait = true,
    remap = false,
  },
})

return M
