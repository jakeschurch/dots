local merge_tables = require("utils").merge_tables

local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
  return
end

local startify = require("alpha.themes.startify")
local _get_file_icon = require("alpha.utils").get_file_icon

startify.file_icons.provider = "devicons"
local function get_file_icon(filepath)
  ---@diagnostic disable-next-line: unused-local
  local icon, _hl = _get_file_icon(startify.file_icons.provider, filepath)
  if icon then
    return icon
  else
    return ""
  end
end

local function add_button(filepath, shortcut_key, text)
  local text_to_show = text or filepath

  return startify.button(
    shortcut_key,
    text_to_show,
    ":e " .. filepath .. "<CR>"
  )
end

local function add_icon_button(filepath, shortcut_key, text)
  local icon_text = (get_file_icon(filepath) or "")
    .. "\t"
    .. (text or filepath)

  return add_button(filepath, shortcut_key, icon_text)
end

function get_mru_dirfiles(dir, n_files)
  dir = dir:gsub("^~", os.getenv("HOME"))

  -- Use 'fd' to find files, then use 'stat' to get modification times, sort by time, and limit the results
  local command = string.format(
    'fd --type f --hidden --exclude .git %s | xargs -I{} stat --format="%%Y %%n" {} | sort -n -r | head -n %d',
    dir,
    n_files
  )

  local handle = io.popen(command)
  local recent_files = {}

  if handle then
    for line in handle:lines() do
      local last_modified, path = line:match("^(%d+) (.+)")
      if last_modified and path then
        table.insert(recent_files, path)
      end
    end
    handle:close()
  end

  return recent_files
end

local function get_git_repos(directory)
  local repos = {}

  directory = directory:gsub("^~", os.getenv("HOME"))

  local handle = io.popen(
    "fd .git$ "
      .. directory
      .. ' -d 2 -u -H  -t d -x stat -c "%Y %n" | sort -n -r | head -n 5'
  )
  if handle then
    for line in handle:lines() do
      local last_modified, path = line:match("(%d+) (.+)")
      if last_modified and path then
        table.insert(
          repos,
          { path = path, last_modified = tonumber(last_modified) }
        )
      end
    end
    handle:close()
  end

  local top_repos = {}
  for i = 1, math.min(5, #repos) do
    table.insert(top_repos, repos[i].path)
  end

  return top_repos
end

startify.section.header.opts.position = "center"
startify.section.header.opts.shrink_margin = true
startify.section.header.val = {
  [[:::::::::    ::::::::      ::::     ::::   ########   :::::::::   ::::::::::]],
  [[:+:    :+:  :+:    :+:     +:+:+: :+:+:+  :+:    :+:  :+:    :+:  :+:]],
  [[+:+    +:+  +:+    +:+     +:+ +:+:+ +:+  +:+    +:+  +:+    +:+  +:+]],
  [[+#+    +:+  +#+    +:+     +#+  +:+  +#+  +#+    +#+  +#++:++#:   +#++:++#]],
  [[+#+    +:+  +#+    +#+     +#+       +#+  +#+    +#+  +#+    +#+  +#+]],
  [[#+#    #+#  #+#    #+#     #+#       #+#  #+#    #+#  #+#    #+#  #+#]],
  [[#########    ########      ###       ###   ########   ###    ###  ##########]],
}

startify.section.mru_git = {
  type = "group",
  val = {
    {
      type = "text",
      val = "MRU Work Projects",
      opts = { hl = "SpecialComment", position = "left" },
    },
    {
      type = "group",
      val = function()
        local expanded_dir = vim.fn.expand("~/Projects/work/")
        local repos = get_git_repos(expanded_dir)

        local buttons = {}
        for i, repo in ipairs(repos) do
          local index = tostring(i + 4)
          repo = repo:gsub("%.git$", "")
          local trimmed_path = repo:gsub(expanded_dir, "")

          table.insert(buttons, add_icon_button(repo, index, trimmed_path))
        end

        return buttons
      end,
      opts = { hl = "SpecialComment", position = "center" },
    },
  },
  opts = { position = "center" },
}

local default_mru_ignore = { "gitcommit" }

startify.mru_opts = {
  auto_cd = true,
  ignore = function(path, ext)
    return (
      string.find(path, "*store*")
      or string.find(path, "COMMIT_EDITMSG")
      or vim.tbl_contains(default_mru_ignore, ext)
      or string.find(path, "*node_modules*")
    )
  end,
}

-- Limit MRU to 5 items and ensure it starts at index 0
startify.section.mru = {
  type = "group",
  val = {
    { type = "padding", val = 1 },
    { type = "text", val = "MRU", opts = { hl = "SpecialComment" } },
    {
      type = "group",
      val = function()
        return { startify.mru(0, nil, 5) }
      end,
      opts = { position = "center" },
    },
  },
}

startify.section.bookmarks = {
  type = "group",
  val = {
    { type = "text", val = "Bookmarks", opts = { hl = "SpecialComment" } },
    {
      type = "group",
      val = {
        add_icon_button("~/.dots/flake.nix", "F", "nix flake"),
        add_icon_button(
          "~/.dots/modules/programs/neovim/default.nix",
          "N",
          "nvim config"
        ),
        add_icon_button("~/.dots/modules/development.nix", "d", "dev env"),
        add_icon_button(
          "~/.dots/modules/programs/git/default.nix",
          "g",
          "git config"
        ),
      },
      opts = { hl = "SpecialComment", position = "center" },
    },
  },
}

startify.section.bottom_buttons = {
  type = "group",
  val = {
    startify.button("e", "New Buffer", ":ene <BAR> startinsert <CR>"),
    startify.button("q", "Quit", "<cmd>q <CR>"),
  },
}

-- disable MRU cwd
startify.section.mru_cwd.val = { { type = "padding", val = 0 } }

startify.opts.autocmd = true

startify.section.footer = {
  type = "text",
  val = require("alpha.fortune")(),
  opts = {
    position = "center",
    hl = "Comment",
  },
}

startify.config.layout = {
  { type = "padding", val = 3 },
  startify.section.header,
  { type = "padding", val = 3 },
  startify.section.mru,
  { type = "padding", val = 2 },
  startify.section.mru_git,
  { type = "padding", val = 2 },
  startify.section.bookmarks,
  { type = "padding", val = 2 },
  startify.section.bottom_buttons,
  { type = "padding", val = 2 },
  startify.section.footer,
  { type = "padding", val = 1 },
}

alpha.setup(startify.config)

vim.keymap.set(
  "n",
  "<leader>e",
  ":Alpha<CR>",
  { noremap = true, silent = true }
)
