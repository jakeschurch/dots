local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")

npairs.setup({
  enable_check_bracket_line = true, -- Avoid jumping to the next line with brackets
  map_cr = true, -- Map Enter for the correct behavior inside brackets
  fast_wrap = {},
  check_ts = true,
})

npairs.add_rules({
  Rule(" ", " "):with_pair(function(opts)
    local pair = opts.line:sub(opts.col - 1, opts.col)
    return vim.tbl_contains({ "()", "[]", "{}" }, pair)
  end),
  Rule(" ", " ", { "markdown", "vimwiki" }):with_pair(function(opts)
    local pair = opts.line:sub(opts.col - 1, opts.col)
    return vim.tbl_contains({ "::" }, pair)
  end),
  Rule(":", ":", { "markdown", "vimwiki" }):with_pair(function()
    return false
  end):with_move(function(opts)
    return opts.prev_char:match(":[a-zA-Z-_]+") ~= nil
  end),
  Rule("( ", " )")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%)") ~= nil
    end)
    :use_key(")"),
  Rule("{ ", " }")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%}") ~= nil
    end)
    :use_key("}"),
  Rule("[ ", " ]")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%]") ~= nil
    end)
    :use_key("]"),
  Rule("<", ">", {
    "typescript",
    "javascript",
    "typescriptreact",
    "javascriptreact",
    "rust",
  }):with_pair(function()
    return false
  end):with_move(function(opts)
    return opts.prev_char:match(".*%>") ~= nil
  end),
})
