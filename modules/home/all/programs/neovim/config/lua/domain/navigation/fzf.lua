local fzf_lua = require("fzf-lua")

local which_key = require("which-key")
local M = {}

local config = {
  { "ivy", "fzf-native" },
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
      ["ctrl-n"] = "preview-page-down",
      ["ctrl-p"] = "preview-page-up",
    },
  },
  files = {
    cwd_prompt_shorten_val = 3,
    cwd_prompt = true,
  },
  winopts = {
    preview = {
      default = "bat_native",
      border = "noborder",
      scrollbar = false,
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
    return nil
  elseif filetype == "fugitive" then
    -- Try to get git root from buffer path
    local dir = vim.fn.fnamemodify(buf_path, ":p:h")
    local git_root =
      vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--show-toplevel" })[1]
    if git_root and git_root ~= "" and not git_root:match("^fatal") then
      return git_root
    end
    return nil
  elseif buf_path == "" or buf_path:match("^[a-z]+://") then
    return nil
  end

  return buf_path
end

local function get_git_root_or_cwd()
  local buf_path = sanitize_buf_path(vim.api.nvim_get_current_buf())
  if not buf_path then
    -- No real file loaded, fallback to current working directory
    return vim.fn.getcwd()
  end

  if vim.fn.isdirectory(buf_path) == 1 then
    return buf_path
  end

  local git_root = vim.fs.root(vim.api.nvim_get_current_buf(), ".git")
  return git_root or vim.fn.fnamemodify(buf_path, ":p:h")
end

-- Create wrapped versions of commonly used fzf commands
local wrapped = {
  git_files = function()
    return fzf_lua.git_files({ cwd = get_git_root_or_cwd() })
  end,
  live_grep = function()
    return fzf_lua.live_grep({ cwd = get_git_root_or_cwd() })
  end,
}

local function recent_git_branches()
  local root = get_git_root_or_cwd()
  local result = vim
    .system({ "git", "-C", root, "reflog" }, { text = true })
    :wait()
  if result.code ~= 0 then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  -- Unique, most recently checked-out branches (skip detached SHAs)
  local branches, seen = {}, {}
  for line in result.stdout:gmatch("[^\r\n]+") do
    local branch = line:match("checkout: moving from %S+ to (%S+)$")
    if
      branch
      and not seen[branch]
      and not branch:match("^%x%x%x%x%x%x%x+$")
    then
      seen[branch] = true
      table.insert(branches, branch)
    end
  end

  fzf_lua.fzf_exec(branches, {
    prompt = "Recent Branches> ",
    cwd = root,
    actions = {
      ["default"] = function(selected)
        if not selected[1] then
          return
        end
        vim.cmd("Git checkout " .. vim.fn.fnameescape(selected[1]))
      end,
    },
  })
end

vim.keymap.set("i", "<C-x><C-f>", function()
  fzf_lua.complete_path()
end, { silent = true, desc = "Fuzzy complete path" })

which_key.add({
  nowait = true,
  remap = false,
  { "<leader>bb", fzf_lua.buffers, desc = "Show Buffers" },
  { "<leader>fc", fzf_lua.command_history, desc = "Command History" },
  { "<leader>fh", fzf_lua.help_tags, desc = "Help Tags" },
  { "<leader>fk", fzf_lua.keymaps, desc = "Keymaps" },
  { "<leader>fm", fzf_lua.manpages, desc = "Man Pages" },
  { "<leader>ja", fzf_lua.resume, desc = "Resume fzf lua search" },
  { "<leader>jj", wrapped.live_grep, desc = "Grep" },
  { "<leader>jk", wrapped.git_files, desc = "Git Files" },
  { "<leader>gb", recent_git_branches, desc = "Checkout Branch" },
  { "<leader>gc", fzf_lua.git_commits, desc = "Checkout Commit" },
  { "<leader>go", fzf_lua.git_status, desc = "Open Changed File" },
})

return M
