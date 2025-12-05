-- checklist/storage.lua
-- Storage for DAG checklist system (per workspace, JSON persistence)

local data_path = vim.fn.stdpath("data") .. "/codecompanion"
local workspace_root = vim.fn.getcwd()
local workspace_id = vim.fn.substitute(workspace_root, '[/\\:*?"<>|]', "_", "g")
local checklist_file = data_path
  .. "/dag_checklists_v1_"
  .. workspace_id
  .. ".json"

vim.fn.mkdir(data_path, "p")

---@class ChecklistStorage
---@field load fun(): (table<integer, DagChecklist>, integer)
---@field save fun(checklists: table<integer, DagChecklist>, next_id: integer)
local ChecklistStorage = {}
ChecklistStorage.__index = ChecklistStorage

function ChecklistStorage.new()
  local self = setmetatable({}, ChecklistStorage)
  return self
end

-- Load DAG checklists from file
function ChecklistStorage:load()
  local ok, data = pcall(vim.fn.readfile, checklist_file)
  if not ok or not data or #data == 0 then
    return {}, 1
  end
  local json_ok, parsed = pcall(vim.json.decode, table.concat(data, "\n"))
  if not json_ok or not parsed then
    return {}, 1
  end
  local checklists = {}
  for checklist_id, checklist in pairs(parsed.checklists or {}) do
    local restored = vim.deepcopy(checklist)
    -- Restore tasks array to indexed table
    if restored.tasks_array then
      restored.tasks = {}
      for i, task in ipairs(restored.tasks_array) do
        restored.tasks[i] = task
      end
      restored.tasks_array = nil
    end
    -- Restore log array
    if restored.log_array then
      restored.log = {}
      for i, entry in ipairs(restored.log_array) do
        restored.log[i] = entry
      end
      restored.log_array = nil
    end
    checklists[tonumber(checklist_id)] = restored
  end
  return checklists, parsed.next_id or 1
end

-- Save DAG checklists to file
function ChecklistStorage:save(checklists, next_id)
  local serializable_checklists = {}
  for checklist_id, checklist in pairs(checklists) do
    local serializable = vim.deepcopy(checklist)
    -- Serialize tasks as array
    local tasks_array = {}
    for i, task in ipairs(checklist.tasks or {}) do
      tasks_array[i] = task
    end
    serializable.tasks_array = tasks_array
    serializable.tasks = nil
    -- Serialize log as array
    local log_array = {}
    for i, entry in ipairs(checklist.log or {}) do
      log_array[i] = entry
    end
    serializable.log_array = log_array
    serializable.log = nil
    serializable_checklists[checklist_id] = serializable
  end
  local data = {
    workspace = workspace_root,
    checklists = serializable_checklists,
    next_id = next_id,
    last_updated = os.time(),
  }
  pcall(vim.fn.writefile, { vim.json.encode(data) }, checklist_file)
end

return {
  new = ChecklistStorage.new,
}
