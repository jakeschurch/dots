-- Auto-loads every lua/plugin/**/*.lua. Modules listed in `lazy` are kept off
-- the critical startup path: a string is the autocmd event that loads them,
-- `true` loads them once the first screen has been drawn.
local lazy = {
  ["plugin.luasnip"] = "InsertEnter",
  ["plugin.llm.copilot"] = "InsertEnter",
  ["plugin.lspsaga"] = "LspAttach",

  ["plugin.colorizer"] = true,
  ["plugin.dap"] = true,
  ["plugin.dap_ui"] = true,
  ["plugin.dap_virtual_text"] = true,
  ["plugin.diffview"] = true,
  ["plugin.gitlinker"] = true,
  ["plugin.grug-far"] = true,
  ["plugin.image"] = true,
  ["plugin.img-clip"] = true,
  ["plugin.null-ls"] = true,
  ["plugin.octo"] = true,
  ["plugin.otter"] = true,
  ["plugin.presenting"] = true,
  ["plugin.render-markdown"] = true,
  ["plugin.toggleterm"] = true,
  ["plugin.trouble"] = true,
  ["plugin.yaml-additional-schemas"] = true,
}

local function load(module_path)
  local ok, err = pcall(require, module_path)
  if not ok then
    vim.notify(
      "Failed to load " .. module_path .. ": " .. err,
      vim.log.levels.ERROR
    )
  end
end

local deferred = {}

for _, filepath in
  ipairs(
    vim.fn.globpath(
      vim.fn.stdpath("config") .. "/lua/plugin",
      "**/*.lua",
      true,
      true
    )
  )
do
  local module_path = filepath:match("lua/(.*)%.lua$"):gsub("/", ".")
  local when = lazy[module_path]

  if when == nil then
    load(module_path)
  elseif when == true then
    table.insert(deferred, module_path)
  else
    vim.api.nvim_create_autocmd(when, {
      once = true,
      callback = function()
        load(module_path)
      end,
    })
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.schedule(function()
      for _, module_path in ipairs(deferred) do
        load(module_path)
      end
    end)
  end,
})
