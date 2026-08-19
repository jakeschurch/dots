-- Loads lua/domain/<capability>/*.lua.
--
-- Each domain has an init.lua returning a spec:
--   first = { "katmai" }         modules loaded before the rest of the domain
--   lazy  = { colorizer = true } true  -> after the first screen draw
--                               "Event" -> on that autocmd, once
-- Anything not listed loads eagerly, in alphabetical order.

-- Colourscheme and UI first so nothing flashes; the rest is alphabetical.
local ORDER = {
  "ui",
  "treesitter",
  "editing",
  "completion",
  "lsp",
  "format",
  "git",
  "navigation",
  "notes",
  "debug",
  "terminal",
  "ai",
}

local root = vim.fn.stdpath("config") .. "/lua/domain"

local function load(module)
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module .. ": " .. err, vim.log.levels.ERROR)
  end
end

local function domains()
  local found =
    vim.split(vim.fn.globpath(root, "*"), "\n", { trimempty = true })
  local names = {}
  for _, path in ipairs(found) do
    if vim.fn.isdirectory(path) == 1 then
      names[vim.fs.basename(path)] = true
    end
  end

  local out = {}
  for _, name in ipairs(ORDER) do
    if names[name] then
      table.insert(out, name)
      names[name] = nil
    end
  end
  for name in vim.spairs(names) do
    table.insert(out, name)
  end
  return out
end

local function members(domain, first)
  local files = vim.split(
    vim.fn.globpath(root .. "/" .. domain, "*.lua"),
    "\n",
    { trimempty = true }
  )

  local rest = {}
  local claimed = {}
  for _, name in ipairs(first) do
    claimed[name] = true
  end

  for _, path in ipairs(files) do
    local name = vim.fs.basename(path):gsub("%.lua$", "")
    if name ~= "init" and not claimed[name] then
      table.insert(rest, name)
    end
  end
  table.sort(rest)

  return vim.list_extend(vim.list_slice(first), rest)
end

local deferred = {}

for _, domain in ipairs(domains()) do
  local ok, spec = pcall(require, "domain." .. domain)
  if not ok or type(spec) ~= "table" then
    spec = {}
  end

  local lazy = spec.lazy or {}

  for _, name in ipairs(members(domain, spec.first or {})) do
    local module = ("domain.%s.%s"):format(domain, name)
    local when = lazy[name]

    if when == nil then
      load(module)
    elseif when == true then
      table.insert(deferred, module)
    else
      vim.api.nvim_create_autocmd(when, {
        once = true,
        callback = function()
          load(module)
        end,
      })
    end
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      for _, module in ipairs(deferred) do
        load(module)
      end
    end)
  end,
})
