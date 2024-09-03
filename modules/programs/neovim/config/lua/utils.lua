local M = {}

M.keymap = function(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

M.try_require = function(plugin_name)
  local status_ok, plugin = pcall(require, plugin_name)
  if not status_ok then
    print("could not load plugin: " .. plugin_name)
    return
  end
  return plugin
end

M.filter = function(func, list)
  local res = {}
  for _, v in ipairs(list) do
    if func(v) then
      res[#res + 1] = v
    end
  end
  return res
end

M.map = function(func, list)
  local out = {}
  for _, v in ipairs(list) do
    out[#out + 1] = func(v)
  end
  return out
end

M.reduce = function(func, x, list)
  for _, v in pairs(list) do
    x = func(x, v)
  end
  return x
end

M.pipe = function(f, ...)
  local fs = { ... }
  return function(...)
    return M.reduce(function(a, f)
      return f(a)
    end, f(...), fs)
  end
end

return M
