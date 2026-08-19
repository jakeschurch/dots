local TEMPLATE_DIR = vim.fs.normalize("~/Documents/Templates")

local templates = nil

local function known()
  if templates then
    return templates
  end

  templates = {}
  local ok, files = pcall(vim.fn.readdir, TEMPLATE_DIR)
  if not ok then
    return templates
  end

  for _, name in ipairs(files) do
    local suffix = name:match("^template%.(%w+)$")
    if suffix then
      templates[suffix] = TEMPLATE_DIR .. "/" .. name
    end
  end
  return templates
end

vim.api.nvim_create_autocmd("BufNewFile", {
  group = vim.api.nvim_create_augroup("templates", { clear = true }),
  callback = function(ev)
    local template = known()[vim.fn.fnamemodify(ev.file, ":e")]
    if template then
      vim.cmd("0r " .. vim.fn.fnameescape(template))
    end
  end,
  desc = "Seed new files from ~/Documents/Templates",
})
