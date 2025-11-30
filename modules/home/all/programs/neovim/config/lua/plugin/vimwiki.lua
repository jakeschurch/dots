vim.treesitter.language.register("markdown", "vimwiki")

vim.cmd([[
let g:vimwiki_tag_format = {'pre': '',
\ 'pre_mark': '@', 'post_mark': '', 'sep': '>><<'}
]])

local g = vim.g

g.automatic_nested_syntaxes = 1
g.vimwiki_autowriteall = 1
g.vimwiki_auto_chdir = 1

g.vimwiki_filetypes = { "markdown" }
-- g.vimwiki_sync_branch = "main"
g.vimwiki_ext = "markdown"

local syntax = "markdown"
local syntax_ext = ".md"

g.vimwiki_list = {
  {
    path = "~/Documents/wiki/work/fieldguide",
    syntax = syntax,
    ext = syntax_ext,
    auto_tags = 1,
    auto_generate_tags = 1,
  },
  {
    path = "~/Documents/wiki/personal",
    syntax = syntax,
    ext = syntax_ext,
    auto_tags = 1,
    auto_generate_tags = 1,
  },
}

-- Remap '-' to <CMD>Oil<CR> in Vimwiki and Markdown filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vimwiki", "markdown" },
  callback = function()
    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "<Tab>",
      "codeium#Accept",
      { noremap = true, silent = true }
    )

    vim.api.nvim_buf_set_keymap(
      0,
      "n",
      "-",
      "<CMD>Oil<CR>",
      { noremap = true, silent = true }
    )
  end,
})

local fzf = require("fzf-lua")

local function relative_path(target, buf_dir)
  -- Make absolute path
  local abs_target = vim.loop.fs_realpath(target)
  local abs_buf = vim.loop.fs_realpath(buf_dir)

  -- Split paths into components
  local function split_path(p)
    local t = {}
    for part in string.gmatch(p, "[^/]+") do
      table.insert(t, part)
    end
    return t
  end

  local target_parts = split_path(abs_target)
  local buf_parts = split_path(abs_buf)

  -- Find common prefix
  local i = 1
  while
    i <= #target_parts
    and i <= #buf_parts
    and target_parts[i] == buf_parts[i]
  do
    i = i + 1
  end
  i = i - 1

  -- Add '..' for each folder difference
  local rel_parts = {}
  for _ = i + 1, #buf_parts do
    table.insert(rel_parts, "..")
  end
  for j = i + 1, #target_parts do
    table.insert(rel_parts, target_parts[j])
  end

  return table.concat(rel_parts, "/")
end

-- Main command to insert markdown link
local function insert_md_link()
  local visual = nil

  -- Capture visual selection if any
  if vim.fn.mode():find("v") then
    vim.cmd('noau normal! "vy')
    visual = vim.fn.getreg("v")
    vim.api.nvim_feedkeys(
      vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
      "x",
      true
    )
  end

  -- Buffer directory
  local buf_path = vim.fn.expand("%:p")
  local buf_dir = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":h") or nil

  -- Git root (to get absolute paths of fzf results)
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  fzf.git_files({
    prompt = "Select file> ",
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end

        local file_rel_to_git = fzf.path.entry_to_file(selected[1]).path
        local abs_target = git_root .. "/" .. file_rel_to_git

        local rel_file = relative_path(abs_target, buf_dir)
        local text = visual or vim.fn.fnamemodify(rel_file, ":t:r") -- filename without extension
        local link = string.format("[%s](%s)", text, rel_file)

        vim.api.nvim_put({ link }, "c", true, true)
      end,
    },
  })
end

vim.keymap.set(
  { "n", "v" },
  "<leader>ml",
  insert_md_link,
  { noremap = true, silent = true }
)
