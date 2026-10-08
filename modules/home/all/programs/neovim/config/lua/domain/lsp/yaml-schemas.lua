local curl = require("plenary.curl")
local M = {
  schemas_catalog = "datreeio/CRDs-catalog",
  schema_catalog_branch = "main",
  github_base_api_url = "https://api.github.com/repos",
  github_headers = {
    Accept = "application/vnd.github+json",
    ["X-GitHub-Api-Version"] = "2022-11-28",
  },
}
M.schema_url = "https://raw.githubusercontent.com/"
  .. M.schemas_catalog
  .. "/"
  .. M.schema_catalog_branch

M.list_github_tree = function()
  local url = M.github_base_api_url
    .. "/"
    .. M.schemas_catalog
    .. "/git/trees/"
    .. M.schema_catalog_branch
  local response =
    curl.get(url, { headers = M.github_headers, query = { recursive = 1 } })
  local ok, body = pcall(vim.json.decode, response.body)
  if not ok or type(body) ~= "table" or type(body.tree) ~= "table" then
    vim.notify(
      "Schema catalog fetch failed: HTTP " .. tostring(response.status),
      vim.log.levels.ERROR
    )
    return nil
  end
  local trees = {}
  for _, tree in ipairs(body.tree) do
    if tree.type == "blob" and tree.path:match("%.json$") then
      table.insert(trees, tree.path)
    end
  end
  return trees
end

M.init = function()
  local all_crds = M.list_github_tree()
  if not all_crds then
    return
  end
  vim.ui.select(all_crds, { prompt = "Select schema: " }, function(selection)
    if not selection then
      vim.notify("Canceled.", vim.log.levels.WARN, {})
      return
    end
    local schema_url = M.schema_url .. "/" .. selection
    local schema_modeline = "# yaml-language-server: $schema=" .. schema_url
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { schema_modeline })
    vim.notify("Added schema modeline: " .. schema_modeline)
  end)
end

vim.api.nvim_create_user_command("GetYamlSchema", function()
  M.init()
end, {})
