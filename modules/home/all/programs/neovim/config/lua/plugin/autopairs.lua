local Rule = require("nvim-autopairs.rule")
local npairs = require("nvim-autopairs")
local cond = require("nvim-autopairs.conds")

local function is_inside_nix_block(opts)
  if vim.bo.filetype ~= "nix" then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  cursor_row = cursor_row - 1 -- 0-based

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "nix")
  if not ok then
    return false
  end

  local tree = parser:parse()[1]
  local root = tree:root()
  local node =
    root:descendant_for_range(cursor_row, cursor_col, cursor_row, cursor_col)

  -- Track if we've seen formals (function parameters)
  local inside_formals = false
  local current = node

  while current do
    local node_type = current:type()

    -- Mark if we're inside function formals
    if node_type == "formals" then
      inside_formals = true
    end

    -- If we're inside an attrset_expression, we want the semicolon
    -- BUT NOT if we're inside formals
    if
      node_type == "attrset_expression"
      or node_type == "rec_attrset_expression"
    then
      return not inside_formals
    end

    -- If we're inside a binding (name = value;), we want the semicolon
    if
      node_type == "binding"
      or node_type == "inherit_from"
      or node_type == "inherit"
    then
      return true
    end

    -- If we're inside a binding_set (the bindings part of let/attrsets)
    if node_type == "binding_set" then
      return true
    end

    -- Special case: if we're in a let_expression, check if we're in the binding area
    if node_type == "let_expression" then
      -- A let_expression has two children: binding_set and body
      -- We want semicolons if we're before the body starts
      local body_node = nil
      for child in current:iter_children() do
        if child:type() ~= "binding_set" then
          body_node = child
          break
        end
      end

      if body_node then
        local body_start_row = body_node:start()
        -- If cursor is before the body, we're in the binding area
        if cursor_row < body_start_row then
          return true
        end
      end
    end

    current = current:parent()
  end

  return false
end

-- Setup with basic options only
npairs.setup({
  enable_check_bracket_line = true,
  map_cr = true,
  fast_wrap = {},
  check_ts = true,
  map_c_w = true,
})

-- Add all custom rules here
npairs.add_rules({
  -- Nix-specific rules for brackets with semicolons
  Rule("{", "};", { "nix" }):with_pair(function(opts)
    -- Don't pair if the previous character is '=' to avoid = {};;
    if opts.prev_char == "=" then
      return false
    end
    return is_inside_nix_block(opts)
  end),

  Rule("[", "];", { "nix" }):with_pair(function(opts)
    -- Don't pair if the previous character is '=' to avoid = [];;
    if opts.prev_char == "=" then
      return false
    end
    return is_inside_nix_block(opts)
  end),

  -- Regular brackets when NOT inside a block (top-level function args)
  Rule("{", "}", { "nix" }):with_pair(function(opts)
    return not is_inside_nix_block(opts)
  end),

  Rule("[", "]", { "nix" }):with_pair(function(opts)
    return not is_inside_nix_block(opts)
  end),

  -- Add semicolon after =
  Rule("=", ";", { "nix" }):with_move(function(opts)
    return false -- Don't move over the semicolon
  end),

  -- Add semicolon after inherit keyword
  Rule("inherit", ";", { "nix" }):with_move(function(opts)
    return false -- Don't move over the semicolon
  end),

  -- Space padding inside brackets
  Rule(" ", " "):with_pair(function(opts)
    local pair = opts.line:sub(opts.col - 1, opts.col)
    return vim.tbl_contains({ "()", "[]", "{}" }, pair)
  end),

  -- Markdown/vimwiki double colon spacing
  Rule(" ", " ", { "markdown", "vimwiki" }):with_pair(function(opts)
    local pair = opts.line:sub(opts.col - 1, opts.col)
    return vim.tbl_contains({ "::" }, pair)
  end),

  -- Colon pairing for emoji/tags
  Rule(":", ":", { "markdown", "vimwiki" }):with_pair(function()
    return false
  end):with_move(function(opts)
    return opts.prev_char:match(":[a-zA-Z-_]+") ~= nil
  end),

  -- Move over closing brackets with space (exclude Nix)
  Rule("( ", " )")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%)") ~= nil
    end)
    :with_pair(cond.not_filetypes({ "nix" }))
    :use_key(")"),

  Rule("{ ", " }")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%}") ~= nil
    end)
    :with_pair(cond.not_filetypes({ "nix" }))
    :use_key("}"),

  Rule("[ ", " ]")
    :with_pair(function()
      return false
    end)
    :with_move(function(opts)
      return opts.prev_char:match(".%]") ~= nil
    end)
    :with_pair(cond.not_filetypes({ "nix" }))
    :use_key("]"),

  -- Angle brackets for type annotations
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
