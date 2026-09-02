-- :Usage <cmd...> — a CLI's own help output in a scratch buffer.
--
-- `:help` is vim's docs and can't be extended, and `:Man` only works for tools
-- that ship man pages (awscli v2 ships none). This just runs the tool and
-- renders what it prints.

-- Pagers hijack the output; force everything through cat.
local ENV = {
  PAGER = "cat",
  MANPAGER = "cat",
  GIT_PAGER = "cat",
  AWS_PAGER = "",
  NO_COLOR = "1",
  TERM = "dumb",
  COLUMNS = "100",
  MANWIDTH = "100",
}

local function strip(text)
  return text
    :gsub("\27%[[0-9;]*[A-Za-z]", "") -- ANSI escapes
    :gsub("\27%][^\7]*\7", "") -- OSC sequences
    :gsub(".\8", "") -- man overstrike bold (X\bX)
    :gsub("\r\n?", "\n")
end

-- `<cmd> help` for subcommand-style tools (aws, git, kubectl), `--help` for
-- the rest. Some tools exit non-zero on help, so output beats exit code.
local function capture(args)
  local attempts = { "help", "--help", "-h" }
  local last

  for _, flag in ipairs(attempts) do
    local cmd = vim.list_extend(vim.list_slice(args), { flag })
    local ok, res = pcall(function()
      return vim.system(cmd, { text = true, env = ENV }):wait()
    end)

    if not ok then
      return nil, tostring(res)
    end

    local out = strip(res.stdout or "")
    if vim.trim(out) ~= "" then
      return out
    end
    last = strip(res.stderr or "")
  end

  return nil, vim.trim(last or "") ~= "" and last or "no help output"
end

local function open(args)
  if #args == 0 then
    vim.notify("Usage: :Usage <command> [subcommand...]", vim.log.levels.ERROR)
    return
  end

  local name = table.concat(args, " ")
  if vim.fn.executable(args[1]) == 0 then
    vim.notify(args[1] .. ": not executable", vim.log.levels.ERROR)
    return
  end

  local text, err = capture(args)
  if not text then
    vim.notify(name .. ": " .. err, vim.log.levels.WARN)
    return
  end

  -- Reuse the window if we're already looking at a usage buffer.
  local title = "usage://" .. name
  local existing = vim.fn.bufnr("^" .. title .. "$")
  if existing ~= -1 then
    vim.api.nvim_buf_delete(existing, { force = true })
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(
    buf,
    0,
    -1,
    false,
    vim.split(text, "\n", { trimempty = false })
  )
  vim.api.nvim_buf_set_name(buf, title)

  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "man"
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  if vim.bo.filetype == "man" or vim.b.usage_win then
    vim.api.nvim_win_set_buf(0, buf)
  else
    vim.cmd.split()
    vim.api.nvim_win_set_buf(0, buf)
  end
  vim.b.usage_win = true

  vim.wo.wrap = false
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.api.nvim_win_set_cursor(0, { 1, 0 })

  vim.keymap.set(
    "n",
    "q",
    "<Cmd>close<CR>",
    { buffer = buf, nowait = true, desc = "Close usage buffer" }
  )
end

-- Complete the first arg against $PATH, later args against the subcommands
-- the tool's own help lists.
local function complete(lead, line)
  local args = vim.split(vim.trim(line), "%s+", { trimempty = true })
  table.remove(args, 1) -- drop ":Usage"
  if lead ~= "" then
    table.remove(args) -- drop the partial word
  end

  if #args == 0 then
    return vim.fn.getcompletion(lead, "shellcmd")
  end

  local text = capture(args)
  if not text then
    return {}
  end

  local seen, out = {}, {}
  for line in vim.gsplit(text, "\n") do
    -- Indented first token, optionally behind a bullet: git's two-column
    -- listing and aws's "o subcommand" bullets both land here. Lower-case
    -- only, so prose and section headings drop out.
    local word = line:match("^%s%s+[o%*%-]?%s*(%l[%w%-%._]+)")
    if word and not seen[word] and vim.startswith(word, lead) then
      seen[word] = true
      table.insert(out, word)
    end
  end
  table.sort(out)
  return out
end

for _, name in ipairs({ "Usage", "Cli" }) do
  vim.api.nvim_create_user_command(name, function(opts)
    open(opts.fargs)
  end, {
    nargs = "+",
    complete = complete,
    desc = "Open a CLI's own usage output in a scratch buffer",
  })
end
