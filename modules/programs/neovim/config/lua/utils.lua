local M = {}

M.ignored_filetypes = {
  "oil",
  "Avante",
  "AvanteInput",
  "TelescopeInput",
  "alpha",
  "dashboard",
  "fugitive",
  "graphql",
  "startify",
  "terminal",
  "toggleterm",
  "TelescopePrompt",
}

M.merge_tables = function(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      M.merge_tables(t1[k], v)
    else
      t1[k] = v
    end
  end
end

M.keymap = function(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
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
