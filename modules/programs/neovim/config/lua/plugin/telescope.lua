local telescope = require("telescope")
local lga_actions = require("telescope-live-grep-args.actions")

local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local themes = require("telescope.themes")

local function get_git_dir()
  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  local result = handle and handle:read("*a") or nil
  if handle then
    handle:close()
  end
  return result and result:gsub("%s+$", "") or nil
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
    theme = "ivy",
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
      "--trim",
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
    file_previewer = previewers.cat.new,
    grep_previewer = previewers.vim_buffer_vimgrep.new,
    qflist_previewer = previewers.vim_buffer_qflist.new,
    mappings = {
      i = {
        ["<C-i>"] = lga_actions.quote_prompt({ search_dirs = get_cwd() }),

        -- freeze the current list and start a fuzzy search in the frozen list
        ["<C-space>"] = actions.to_fuzzy_refine,
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
    file_ignore_patterns = lines_from("~/.rgignore"),

    layout_strategy = "vertical",
    layout_config = {
      vertical = { width = 0.8 },
      preview_cutoff = 1,
    },
    preview = {
      mime_hook = function(filepath, bufnr, opts)
        local is_image = function(filepath)
          local image_extensions = { "png", "jpg" } -- Supported image formats
          local split_path = vim.split(filepath:lower(), ".", { plain = true })
          local extension = split_path[#split_path]
          return vim.tbl_contains(image_extensions, extension)
        end
        if is_image(filepath) then
          local term = vim.api.nvim_open_term(bufnr, {})
          local function send_output(_, data, _)
            for _, d in ipairs(data) do
              vim.api.nvim_chan_send(term, d .. "\r\n")
            end
          end
          vim.fn.jobstart({
            "catimg",
            filepath, -- Terminal image viewer command
          }, {
            on_stdout = send_output,
            stdout_buffered = true,
            pty = true,
          })
        else
          require("telescope.previewers.utils").set_preview_message(
            bufnr,
            opts.winid,
            "Binary cannot be previewed"
          )
        end
      end,
    },
  },
  pickers = {
    find_files = {
      theme = "ivy",
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
      mappings = {
        n = {
          ["cd"] = function(prompt_bufnr)
            local selection =
              require("telescope.actions.state").get_selected_entry()
            local dir = vim.fn.fnamemodify(selection.path, ":p:h")
            require("telescope.actions").close(prompt_bufnr)
            -- Depending on what you want put `cd`, `lcd`, `tcd`
            vim.cmd(string.format("silent lcd %s", dir))
          end,
        },
      },
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
    fzy_native = {
      override_generic_sorter = true,
      override_file_sorter = true,
    },
    fzf = {
      fuzzy = true,
      override_generic_sorter = false,
      override_file_sorter = true,
      case_mode = "smart_case",
      themes = {},
      terms = {},
    },
  },
})

local which_key = require("which-key")
local builtin = require("telescope.builtin")
local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")

local telescope_mappings = {
  {
    "<leader>bb",
    builtin.buffers,
    desc = "Show Buffers",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fc",
    builtin.command_history,
    desc = "Command History",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fg",
    builtin.git_branches,
    desc = "Git Branches",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fh",
    builtin.help_tags,
    desc = "Help Tags",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fk",
    builtin.keymaps,
    desc = "Keymaps",
    nowait = true,
    remap = false,
  },
  {
    "<leader>fm",
    builtin.man_pages,
    desc = "Man Pages",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gb",
    builtin.git_branches,
    desc = "Checkout Branch",
    nowait = true,
    remap = false,
  },
  {
    "<leader>gc",
    builtin.git_commits,
    desc = "Checkout Commit",
    nowait = true,
    remap = false,
  },
  {
    "<leader>go",
    builtin.git_status,
    desc = "Open Changed File",
    nowait = true,
    remap = false,
  },
  {
    "<leader>jh",
    live_grep_args_shortcuts.grep_word_under_cursor,
    desc = "Grep Word Under Cursor",
    nowait = true,
    remap = false,
  },
  {
    "<leader>ji",
    function()
      telescope.extensions.live_grep_args.live_grep_args({ cwd = get_cwd() })
    end,
    desc = "Live Grep Args",
    nowait = true,
    remap = false,
  },
  {
    "<leader>jj",
    function()
      builtin.live_grep({ cwd = get_cwd() })
    end,
    desc = "Live Grep",
    nowait = true,
    remap = false,
  },
  {
    "<leader>jk",
    builtin.git_files,
    desc = "Git Files",
    nowait = true,
    remap = false,
  },
}

which_key.add(telescope_mappings)

-- Additional non-leader mappings
vim.keymap.set("n", "<C-p>", function()
  builtin.find_files({ cwd = get_cwd() })
end, { silent = true, noremap = true })

vim.api.nvim_create_autocmd("User", {
  pattern = "TelescopePreviewerLoaded",
  callback = function(_)
    vim.wo.wrap = true
  end,
})

telescope.load_extension("live_grep_args")
telescope.load_extension("ui-select")
telescope.load_extension("fzf")
telescope.load_extension("fzy_native")
