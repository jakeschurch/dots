local telescope = require("telescope")

local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local themes = require("telescope.themes")

local function get_git_dir()
  local command = "git rev-parse --show-toplevel"
  local status = os.execute(command)

  if status == 0 then
    local handle = io.popen(command)
    if handle then
      local git_root_path = handle:read("*a")
      handle:close()
      if git_root_path then
        return git_root_path:gsub("[\n\r]", "")
      end
    end
  end
  return nil
end

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then
    f:close()
  end
  return f ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
local function lines_from(file)
  if not file_exists(file) then
    return {}
  end
  local lines = {}
  for line in io.lines(file) do
    if line then
      lines[#lines + 1] = line
    end
  end
  return lines
end

local function get_cwd()
  local buffer_dir = require("telescope.utils").buffer_dir()

  if string.find(buffer_dir, "%.git") then
    buffer_dir = vim.fn.fnamemodify(buffer_dir, ":h")
  end

  if string.find(buffer_dir, "fugitive://") then
    buffer_dir = string.gsub(buffer_dir, "fugitive://", "")
  end

  local git_root_path = get_git_dir()

  if git_root_path then
    return git_root_path
  else
    return buffer_dir
  end
end

local ui_select_theme = {
  themes.get_ivy({
    -- even more opts
    width = 0.8,
    previewer = true,
    prompt_title = false,
    borderchars = {
      { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
  }),
}

telescope.setup({
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--hidden",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--ignore-file=~/.rgignore",
      "--column",
      "--smart-case",
      "--pcre2",
    },
    path_display = { "truncate" },
    shorten_path = true,
    color_devicons = true,
    border = {},
    borderchars = {
      { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
      preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    },
    set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    file_previewer = previewers.vim_buffer_cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    -- Developer configurations: Not meant for general override
    buffer_previewer_maker = previewers.buffer_previewer_maker,
    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        ["<C-c>"] = actions.close,
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-h>"] = "which_key",
      },
      n = {
        ["<esc>"] = actions.close,
        ["q"] = actions.close,

        ["gg"] = actions.move_to_top,
        ["G"] = actions.move_to_bottom,

        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,

        ["j"] = actions.move_selection_next,
        ["k"] = actions.move_selection_previous,
        ["H"] = actions.move_to_top,
        ["M"] = actions.move_to_middle,
        ["L"] = actions.move_to_bottom,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,
      },
    },
    -- read from ~/.rgignore
    file_ignore_patterns = lines_from("~/.rgignore"),

    layout_strategy = "vertical",
    layout_config = {
      vertical = { width = 0.8 },
    },
  },
  pickers = {
    find_files = {
      theme = "ivy",
    },
    buffers = {
      theme = "ivy",
    },
    live_grep = {
      theme = "ivy",
    },
    git_files = {
      theme = "ivy",
    },
  },
  extensions = {
    ["ui-select"] = themes.get_dropdown({
      -- even more opts
      width = 0.8,
      previewer = true,
      prompt_title = false,
      borderchars = {
        { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
        prompt = { "─", "│", " ", "│", "┌", "┐", "│", "│" },
        results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
        preview = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
      },
    }),
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
      themes = {},
      terms = {},
    },
    preview = {},
  },
})

local keymap = require("utils").keymap
local builtin = require("telescope.builtin")

local keymap_opts = { silent = true, noremap = true }
keymap("n", "<leader>jk", builtin.git_files, keymap_opts)

vim.keymap.set("n", "<C-p>", function()
  builtin.find_files({ cwd = get_cwd() })
end, keymap_opts)

keymap("n", "<leader>jj", function()
  builtin.live_grep({ cwd = get_cwd() }, keymap_opts)
end)

keymap("n", "<leader>jh", function()
  builtin.live_grep({ cwd = os.getenv("HOME") })
end, keymap_opts)
keymap("n", "<leader>bb", builtin.buffers, keymap_opts)
keymap("n", "<leader>fm", builtin.man_pages, keymap_opts)
keymap("n", "<leader>fh", builtin.help_tags, keymap_opts)
keymap("n", "<leader>fc", builtin.command_history, keymap_opts)

telescope.load_extension("ui-select")
telescope.load_extension("fzf")
