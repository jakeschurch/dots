local M = {}

M.executeCommand = function(command)
  local output, status, _, _ = hs.execute(command)
  return output, status
end

M.getSystem = function()
  return M.executeCommand("uname -s")
end

M.wrap = function(lambda)
  return function()
    lambda()
  end
end

return M
