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

local function get_mru_projects(directory, n_projects)
  directory = vim.fn.expand(directory)
  local seen = {}
  local projects = {}

  for _, file in ipairs(vim.v.oldfiles) do
    if #projects >= n_projects then
      break
    end
    -- Check if file is under the target directory
    if file:sub(1, #directory) == directory then
      -- Extract the project dir (first path component after directory)
      local relative = file:sub(#directory + 1)
      local project_name = relative:match("^([^/]+)")
      if project_name and not seen[project_name] then
        seen[project_name] = true
        table.insert(projects, directory .. project_name)
      end
    end
  end

  return projects
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

startify.section.mru_projects = {
  type = "group",
  val = {
    {
      type = "text",
      val = "MRU Projects",
      opts = { hl = "SpecialComment", position = "left" },
    },
    {
      type = "group",
      val = function()
        local projects_dir = "~/Projects/"
        local projects = get_mru_projects(projects_dir, 5)
        local expanded_dir = vim.fn.expand(projects_dir)

        local buttons = {}
        for i, project in ipairs(projects) do
          local index = tostring(i + 4)
          local trimmed_path = project:gsub(expanded_dir, "")
          table.insert(buttons, add_icon_button(project, index, trimmed_path))
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
        add_icon_button("~/.dots/flake.nix", "d", "nix flake"),
      },
      opts = { hl = "SpecialComment", position = "center" },
    },
  },
}

startify.section.bottom_buttons = {
  type = "group",
  val = {
    startify.button("e", "New Buffer", ":ene <BAR> startinsert <CR>"),
    startify.button("Q", "Quit", "<cmd>q <CR>"),
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
  startify.section.mru_projects,
  { type = "padding", val = 2 },
  startify.section.bookmarks,
  { type = "padding", val = 2 },
  startify.section.bottom_buttons,
  { type = "padding", val = 2 },
  startify.section.footer,
  { type = "padding", val = 1 },
}

alpha.setup(startify.config)

-- Refresh alpha when entering the buffer to update MRU
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    if vim.bo.filetype == "alpha" then
      vim.schedule(function()
        require("alpha").redraw()
      end)
    end
  end,
})

vim.keymap.set("n", "<leader>e", function()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.api.nvim_get_option_value("filetype", { buf = buf }) == "alpha"
    then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  vim.cmd("Alpha")
end, { noremap = true, silent = true })
