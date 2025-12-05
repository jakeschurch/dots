---@diagnostic disable: undefined-field
-- write_file.lua --------------------------------------------------------------

---@class WriteFileToolArgs
---@field file_path string Absolute path of the file to write
---@field content   string Content to write to the file

---@class EditFileToolArgs
---@field file_path string Absolute path of the file to edit
---@field old_string string The text to replace
---@field new_string string The text to replace it with
---@field replace_all boolean? Replace all occurrences (default false)

---@class MultiEditFileToolArgs
---@field file_path string Absolute path of the file to edit
---@field edits EditFileToolArgs[] Array of edit operations to perform sequentially

---@class FileToolMetadata
---@field file_path   string
---@field exists      boolean
---@field title       string
---@field formatted   boolean
---@field diagnostics table[]
---@field diff        string?

---@class FileToolResult
---@field metadata FileToolMetadata
---@field output   string

local libuv = vim.uv

-- Shared utility functions
local function file_exists(p)
  return libuv.fs_stat(p) ~= nil
end
local function rel_path(abs)
  local cwd = libuv.cwd()
  return abs:sub(1, #cwd) == cwd and abs:sub(#cwd + 2) or abs
end

-- Shared LSP async wait (non-blocking, event-driven)
local function wait_lsp_async(bufnr, timeout_ms, callback)
  if #vim.lsp.get_clients({ bufnr = bufnr }) > 0 then
    callback(true)
    return
  end

  local ready = false
  local aug =
    vim.api.nvim_create_augroup("FileTool_LspAttach", { clear = false })

  local cleanup = function()
    pcall(vim.api.nvim_del_augroup_by_id, aug)
  end

  local id = vim.api.nvim_create_autocmd("LspAttach", {
    group = aug,
    callback = function(ev)
      if ev.buf == bufnr and not ready then
        ready = true
        cleanup()
        pcall(vim.api.nvim_del_autocmd, id)
        vim.schedule(function()
          callback(true)
        end)
      end
    end,
  })

  vim.defer_fn(function()
    if not ready then
      ready = true
      cleanup()
      pcall(vim.api.nvim_del_autocmd, id)
      vim.schedule(function()
        callback(false)
      end)
    end
  end, timeout_ms)
end

-- Shared async diagnostics collection (event-driven, no polling)
local function collect_diags_async(bufnr, timeout_ms, callback)
  vim.diagnostic.reset(nil, bufnr)

  local aug = vim.api.nvim_create_augroup("FileTool_Diag", { clear = false })
  local done = false

  local function finish()
    if done then
      return
    end
    done = true
    pcall(vim.api.nvim_del_augroup_by_id, aug)
    vim.schedule(function()
      callback(vim.diagnostic.get(bufnr))
    end)
  end

  -- Listen for diagnostic changes
  local id = vim.api.nvim_create_autocmd("DiagnosticChanged", {
    group = aug,
    buffer = bufnr,
    callback = function()
      local diags = vim.diagnostic.get(bufnr)
      -- Only finish if there are any diagnostics (could be errors, warnings, etc.)
      if #diags > 0 then
        finish()
      end
    end,
  })

  -- Fallback timeout
  vim.defer_fn(function()
    pcall(vim.api.nvim_del_autocmd, id)
    finish()
  end, timeout_ms)
end

-- Shared LSP formatting and diagnostics workflow
local function process_file_with_lsp(bufnr, file_path, callback)
  wait_lsp_async(bufnr, 5000, function(has_lsp)
    local formatting_done = false
    local formatting_triggered = false
    local callback_executed = false

    local function safe_cleanup_and_callback(diag_fmt)
      if callback_executed then
        return
      end
      callback_executed = true

      vim.schedule(function()
        -- Safely delete buffer if it still exists
        if vim.api.nvim_buf_is_valid(bufnr) then
          pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end

        -- Filter diagnostics to only include errors (severity 1)
        local errors = {}
        for _, d in ipairs(diag_fmt) do
          if d.severity == 1 then
            table.insert(errors, d)
          end
        end

        callback({
          has_lsp = has_lsp,
          formatted = formatting_triggered,
          errors = errors,
        })
      end)
    end

    local function start_diagnostics()
      collect_diags_async(bufnr, 15000, function(diag_fmt)
        safe_cleanup_and_callback(diag_fmt)
      end)
    end

    if has_lsp then
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          local clients = vim.lsp.get_clients({ bufnr = bufnr })
          if #clients > 0 then
            formatting_triggered = true

            pcall(function()
              vim.lsp.buf_request(bufnr, "textDocument/formatting", {
                textDocument = { uri = vim.uri_from_bufnr(bufnr) },
                options = { insertSpaces = true, tabSize = 2 },
              }, function(err, result)
                formatting_done = true
                if not err and result and next(result) then
                  vim.schedule(function()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                      vim.lsp.util.apply_text_edits(
                        result,
                        bufnr,
                        clients[1].offset_encoding
                      )
                      if vim.bo[bufnr].modified then
                        vim.api.nvim_buf_call(bufnr, function()
                          vim.cmd.write({ mods = { silent = true } })
                        end)
                      end
                    end
                    -- Start diagnostics after formatting is applied
                    start_diagnostics()
                  end)
                else
                  -- No formatting edits or error, proceed to diagnostics
                  start_diagnostics()
                end
              end)
            end)

            -- Safety net: if formatting never responds, start diagnostics anyway
            vim.defer_fn(function()
              if not formatting_done then
                formatting_done = true
                start_diagnostics()
              end
            end, 2000)
          else
            start_diagnostics()
          end
        else
          start_diagnostics()
        end
      end)
    else
      safe_cleanup_and_callback({})
    end
  end)
end

-- Smart string replacement with multiple strategies (for edit tool)
local function smart_replace(content, old_string, new_string, replace_all)
  if old_string == new_string then
    error("old_string and new_string must be different")
  end

  -- Strategy 1: Simple exact match
  local function try_simple()
    if replace_all then
      if content:find(old_string, 1, true) then
        return content:gsub(vim.pesc(old_string), new_string:gsub("%%", "%%%%"))
      end
    else
      local first_pos = content:find(old_string, 1, true)
      if first_pos then
        local last_pos = content:find(old_string, first_pos + #old_string, true)
        if not last_pos then -- Only one occurrence
          local before = content:sub(1, first_pos - 1)
          local after = content:sub(first_pos + #old_string)
          return before .. new_string .. after
        end
      end
    end
    return nil
  end

  -- Strategy 2: Line-trimmed matching
  local function try_line_trimmed()
    local content_lines = vim.split(content, "\n", { plain = true })
    local search_lines = vim.split(old_string, "\n", { plain = true })

    if #search_lines == 0 then
      return nil
    end

    -- Remove trailing empty line if present
    if search_lines[#search_lines] == "" then
      table.remove(search_lines)
    end

    for i = 1, #content_lines - #search_lines + 1 do
      local matches = true

      for j = 1, #search_lines do
        local content_trimmed = vim.trim(content_lines[i + j - 1])
        local search_trimmed = vim.trim(search_lines[j])

        if content_trimmed ~= search_trimmed then
          matches = false
          break
        end
      end

      if matches then
        local match_lines = {}
        for j = 1, #search_lines do
          table.insert(match_lines, content_lines[i + j - 1])
        end
        local match_text = table.concat(match_lines, "\n")

        if replace_all then
          return content:gsub(
            vim.pesc(match_text),
            new_string:gsub("%%", "%%%%")
          )
        else
          local pos = content:find(vim.pesc(match_text))
          if
            pos and not content:find(vim.pesc(match_text), pos + #match_text)
          then
            return content:gsub(
              vim.pesc(match_text),
              new_string:gsub("%%", "%%%%"),
              1
            )
          end
        end
      end
    end
    return nil
  end

  -- Strategy 3: Whitespace normalized matching
  local function try_whitespace_normalized()
    local function normalize_ws(text)
      return vim.trim(text:gsub("%s+", " "))
    end

    local normalized_old = normalize_ws(old_string)
    local content_lines = vim.split(content, "\n", { plain = true })

    for i, line in ipairs(content_lines) do
      if normalize_ws(line) == normalized_old then
        if replace_all then
          content_lines[i] = new_string
        else
          -- Check if this is the only match
          local other_matches = 0
          for j, other_line in ipairs(content_lines) do
            if j ~= i and normalize_ws(other_line) == normalized_old then
              other_matches = other_matches + 1
            end
          end
          if other_matches == 0 then
            content_lines[i] = new_string
            return table.concat(content_lines, "\n")
          end
        end
      end
    end

    if replace_all then
      return table.concat(content_lines, "\n")
    end
    return nil
  end

  -- Try strategies in order
  local result = try_simple()
  if result then
    return result
  end

  result = try_line_trimmed()
  if result then
    return result
  end

  result = try_whitespace_normalized()
  if result then
    return result
  end

  error(
    "old_string not found in content or found multiple times (use replace_all for multiple occurrences)"
  )
end

-- Simple diff generation
local function create_diff(old_content, new_content, filepath)
  if old_content == new_content then
    return "No changes"
  end

  local old_lines = vim.split(old_content, "\n", { plain = true })
  local new_lines = vim.split(new_content, "\n", { plain = true })

  local diff_lines = {}
  table.insert(diff_lines, "--- " .. filepath)
  table.insert(diff_lines, "+++ " .. filepath)

  local max_lines = math.max(#old_lines, #new_lines)
  for i = 1, max_lines do
    local old_line = old_lines[i] or ""
    local new_line = new_lines[i] or ""

    if old_line ~= new_line then
      if old_lines[i] then
        table.insert(diff_lines, "-" .. old_line)
      end
      if new_lines[i] then
        table.insert(diff_lines, "+" .. new_line)
      end
    end
  end

  return table.concat(diff_lines, "\n")
end

local function format_output_object(obj)
  if type(obj) == "table" and obj.output then
    return tostring(obj.output)
  elseif type(obj) == "string" then
    return obj
  elseif type(obj) == "table" and obj.data and obj.data.output then
    return tostring(obj.data.output)
  elseif
    type(obj) == "table"
    and obj.data
    and obj.data.metadata
    and obj.data.metadata.file_path
  then
    return ("File processed: %s\n"):format(obj.data.metadata.file_path)
  else
    return vim.inspect(obj)
  end
end

local function make_handlers(tag)
  return {
    success = function(tool, agent, _, out)
      agent.chat:add_tool_output(tool, format_output_object(out[1] or out))
    end,
    error = function(tool, agent, _, err)
      local msg = format_output_object(err[1] or err)
      agent.chat:add_tool_output(tool, ("[ERROR] %s: %s"):format(tag, msg))
    end,
    rejected = function(tool, agent)
      agent.chat:add_tool_output(
        tool,
        ("[REJECTED] %s: User declined the operation."):format(tag)
      )
    end,
  }
end

---@type CodeCompanion.Agent.Tool
local WriteFileTool = {
  name = "write_file",

  cmds = {
    ---@param _agent CodeCompanion.Agent
    ---@param args  WriteFileToolArgs
    ---@param _in   any
    ---@param cb    fun(res:{status:string, data:any})
    function(_agent, args, _in, cb)
      local path, content = args.file_path, args.content
      if not path or path == "" then
        return cb({ status = "error", data = "file_path required" })
      end
      if content == nil then
        return cb({ status = "error", data = "content required" })
      end
      if type(content) == "table" then
        content = vim.islist(content) and table.concat(content, "\n")
          or vim.inspect(content)
      end
      if not path:match("^/") and not path:match("^[A-Za-z]:[\\/]") then
        return cb({ status = "error", data = "file_path must be absolute" })
      end

      local existed = file_exists(path)
      local ok, err = pcall(function()
        vim.fn.writefile(vim.split(content, "\n", { plain = true }), path)
      end)
      if not ok then
        return cb({ status = "error", data = "Write failed: " .. tostring(err) })
      end

      local bufnr = vim.fn.bufadd(path)
      vim.fn.bufload(bufnr)
      local ft = vim.filetype.match({ filename = path })
      if ft then
        vim.bo[bufnr].filetype = ft
      end

      process_file_with_lsp(bufnr, path, function(result)
        local output = ("File written: %s\n"):format(path)

        if #result.errors > 0 then
          output = output .. ("LSP errors: %d found.\n"):format(#result.errors)
          for _, d in ipairs(result.errors) do
            output = output
              .. ("[ERROR] line %d: %s\n"):format((d.lnum or 0) + 1, d.message)
          end
        else
          output = output .. "No LSP errors found.\n"
        end

        if result.formatted then
          output = output .. "Formatting applied successfully.\n"
        end

        cb({
          status = "success",
          data = {
            metadata = {
              file_path = path,
              exists = existed,
              title = rel_path(path),
              formatted = result.formatted,
              diagnostics = result.errors,
            },
            output = output,
          },
        })
      end)
    end,
  },

  opts = { requires_approval = true },
  system_prompt = [[## Write File Tool

Performs file writes and formatting in the codebase.

Usage:
- You MUST use the Read tool at least once in the conversation before writing or editing a file. This tool will error if you attempt to write without reading the file first.
- When writing or editing, preserve the exact indentation (tabs/spaces) as it appears in the file. Do not add or remove indentation unless explicitly instructed.
- ALWAYS prefer editing existing files in the codebase. NEVER write new files unless explicitly required.
- NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
- Only use emojis if the user explicitly requests it. Avoid writing emojis to files unless asked.
- The tool will overwrite the existing file if there is one at the provided path.
- After writing, the file will be checked for LSP diagnostics and formatted asynchronously if possible.
- Pay attention to LSP diagnostics in the output to ensure code quality.
]],

  schema = {
    type = "function",
    ["function"] = {
      name = "write_file",
      description = "Write a file, format it via LSP, and return diagnostics.",
      parameters = {
        type = "object",
        properties = {
          file_path = { type = "string", description = "Absolute path" },
          content = { type = "string", description = "File contents" },
        },
        required = { "file_path", "content" },
      },
      strict = true,
    },
  },

  function_call = {},
  env = nil,
  handlers = {},
  args = {},
  tool = {},

  output = make_handlers("Write File Tool"),

  ["output.prompt"] = function(tool)
    local txt = tool.args and tool.args.content or ""
    if type(txt) == "table" then
      txt = vim.islist(txt) and table.concat(txt, "\n") or vim.inspect(txt)
    end
    if #txt > 200 then
      txt = txt:sub(1, 200) .. "..."
    end
    return ("Write to file: %s\n\nContent preview:\n%s\n\nFile will be formatted (async) and analysed by LSP."):format(
      tool.args and tool.args.file_path or "",
      txt
    )
  end,
}

---@type CodeCompanion.Agent.Tool
local EditFileTool = {
  name = "edit_file",

  cmds = {
    ---@param _agent CodeCompanion.Agent
    ---@param args  EditFileToolArgs
    ---@param _in   any
    ---@param cb    fun(res:{status:string, data:any})
    function(_agent, args, _in, cb)
      local path = args.file_path
      local old_string = args.old_string
      local new_string = args.new_string
      local replace_all = args.replace_all or false

      if not path or path == "" then
        return cb({ status = "error", data = "file_path required" })
      end
      if not old_string then
        return cb({ status = "error", data = "old_string required" })
      end
      if not new_string then
        return cb({ status = "error", data = "new_string required" })
      end
      if old_string == new_string then
        return cb({
          status = "error",
          data = "old_string and new_string must be different",
        })
      end
      if not path:match("^/") and not path:match("^[A-Za-z]:[\\/]") then
        return cb({ status = "error", data = "file_path must be absolute" })
      end

      if not file_exists(path) then
        return cb({ status = "error", data = "File does not exist: " .. path })
      end

      -- Read original content
      local ok, original_content = pcall(function()
        return table.concat(vim.fn.readfile(path), "\n")
      end)
      if not ok then
        return cb({
          status = "error",
          data = "Failed to read file: " .. tostring(original_content),
        })
      end

      -- Perform smart replacement
      local new_content
      ok, new_content = pcall(
        smart_replace,
        original_content,
        old_string,
        new_string,
        replace_all
      )
      if not ok then
        return cb({ status = "error", data = tostring(new_content) })
      end

      -- Write the modified content
      ok, err = pcall(function()
        vim.fn.writefile(vim.split(new_content, "\n", { plain = true }), path)
      end)
      if not ok then
        return cb({ status = "error", data = "Write failed: " .. tostring(err) })
      end

      local bufnr = vim.fn.bufadd(path)
      vim.fn.bufload(bufnr)

      -- Ensure buffer content matches the new file content for LSP analysis
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          local lines = vim.split(new_content, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
          local ft = vim.filetype.match({ filename = path })
          if ft then
            vim.bo[bufnr].filetype = ft
          end
          vim.bo[bufnr].modified = false

          -- Small delay to ensure LSP attaches and analyzes
          vim.defer_fn(function()
            local diff = create_diff(original_content, new_content, path)
            process_file_with_lsp(bufnr, path, function(result)
              local output = ("File edited: %s\n\n"):format(path)

              if #result.errors > 0 then
                output = output
                  .. ("\nLSP errors: %d found.\n"):format(#result.errors)
                for _, d in ipairs(result.errors) do
                  output = output
                    .. ("[ERROR] line %d: %s\n"):format(
                      (d.lnum or 0) + 1,
                      d.message
                    )
                end
              else
                output = output .. "No LSP errors found.\n"
              end

              if result.formatted then
                output = output .. "Formatting applied successfully.\n"
              end

              cb({
                status = "success",
                data = {
                  metadata = {
                    file_path = path,
                    exists = true,
                    title = rel_path(path),
                    formatted = result.formatted,
                    diagnostics = result.errors,
                    diff = diff,
                  },
                  output = output,
                },
              })
            end)
          end, 100)
        end
      end)
    end,
  },

  opts = { requires_approval = true },
  system_prompt = [[## Edit File Tool

Performs exact string replacements in files with LSP formatting and analysis.

Usage:
- You MUST use the Read tool at least once in the conversation before editing. This tool will error if you attempt an edit without reading the file.
- When editing text from Read tool output, preserve exact indentation (tabs/spaces) as it appears AFTER the line number prefix. Never include line number prefixes in old_string or new_string.
- ALWAYS prefer editing existing files. NEVER write new files unless explicitly required.
- Only use emojis if explicitly requested by the user.
- The edit will FAIL if old_string is not unique in the file. Either provide more surrounding context to make it unique or use replace_all for multiple instances.
- Use replace_all for renaming variables or replacing multiple occurrences of the same string.
- The tool uses smart matching strategies: exact match, line-trimmed matching, and whitespace-normalized matching.
- After editing, the file will be formatted via LSP and checked for diagnostics.
]],

  schema = {
    type = "function",
    ["function"] = {
      name = "edit_file",
      description = "Edit a file by replacing old_string with new_string, format via LSP, and return diagnostics.",
      parameters = {
        type = "object",
        properties = {
          file_path = {
            type = "string",
            description = "Absolute path to the file to edit",
          },
          old_string = {
            type = "string",
            description = "The text to replace (must be unique unless replace_all is true)",
          },
          new_string = {
            type = "string",
            description = "The text to replace it with",
          },
          replace_all = {
            type = "boolean",
            description = "Replace all occurrences of old_string (default false)",
          },
        },
        required = { "file_path", "old_string", "new_string" },
      },
      strict = true,
    },
  },

  function_call = {},
  env = nil,
  handlers = {},
  args = {},
  tool = {},

  output = make_handlers("Edit File Tool"),

  ["output.prompt"] = function(tool)
    local old_txt = tool.args and tool.args.old_string or ""
    local new_txt = tool.args and tool.args.new_string or ""
    if #old_txt > 100 then
      old_txt = old_txt:sub(1, 100) .. "..."
    end
    if #new_txt > 100 then
      new_txt = new_txt:sub(1, 100) .. "..."
    end
    local replace_all = tool.args and tool.args.replace_all and " (replace all)"
      or ""
    return ("Edit file: %s%s\n\nReplace:\n%s\n\nWith:\n%s\n\nFile will be formatted and analysed by LSP."):format(
      tool.args and tool.args.file_path or "",
      replace_all,
      old_txt,
      new_txt
    )
  end,
}

---@type CodeCompanion.Agent.Tool
local MultiEditFileTool = {
  name = "multiedit_file",

  cmds = {
    ---@param _agent CodeCompanion.Agent
    ---@param args  MultiEditFileToolArgs
    ---@param _in   any
    ---@param cb    fun(res:{status:string, data:any})
    function(_agent, args, _in, cb)
      local path = args.file_path
      local edits = args.edits

      if not path or path == "" then
        return cb({ status = "error", data = "file_path required" })
      end
      if not edits or type(edits) ~= "table" or #edits == 0 then
        return cb({
          status = "error",
          data = "edits array required and must not be empty",
        })
      end
      if not path:match("^/") and not path:match("^[A-Za-z]:[\\/]") then
        return cb({ status = "error", data = "file_path must be absolute" })
      end

      if not file_exists(path) then
        return cb({ status = "error", data = "File does not exist: " .. path })
      end

      -- Read original content
      local ok, original_content = pcall(function()
        return table.concat(vim.fn.readfile(path), "\n")
      end)
      if not ok then
        return cb({
          status = "error",
          data = "Failed to read file: " .. tostring(original_content),
        })
      end

      -- Validate all edits first
      for i, edit in ipairs(edits) do
        if not edit.old_string then
          return cb({
            status = "error",
            data = ("Edit #%d: old_string required"):format(i),
          })
        end
        if not edit.new_string then
          return cb({
            status = "error",
            data = ("Edit #%d: new_string required"):format(i),
          })
        end
        if edit.old_string == edit.new_string then
          return cb({
            status = "error",
            data = ("Edit #%d: old_string and new_string must be different"):format(
              i
            ),
          })
        end
      end

      -- Apply edits sequentially
      local current_content = original_content
      local edit_results = {}

      for i, edit in ipairs(edits) do
        local old_string = edit.old_string
        local new_string = edit.new_string
        local replace_all = edit.replace_all or false

        local success, new_content = pcall(
          smart_replace,
          current_content,
          old_string,
          new_string,
          replace_all
        )
        if not success then
          return cb({
            status = "error",
            data = ("Edit #%d failed: %s"):format(i, tostring(new_content)),
          })
        end

        table.insert(edit_results, {
          edit_number = i,
          old_string = old_string,
          new_string = new_string,
          replace_all = replace_all,
        })

        current_content = new_content
      end

      -- Write the final modified content
      ok, err = pcall(function()
        vim.fn.writefile(
          vim.split(current_content, "\n", { plain = true }),
          path
        )
      end)
      if not ok then
        return cb({ status = "error", data = "Write failed: " .. tostring(err) })
      end

      local bufnr = vim.fn.bufadd(path)
      vim.fn.bufload(bufnr)

      -- Ensure buffer content matches the new file content for LSP analysis
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(bufnr) then
          local lines = vim.split(current_content, "\n", { plain = true })
          vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
          local ft = vim.filetype.match({ filename = path })
          if ft then
            vim.bo[bufnr].filetype = ft
          end
          vim.bo[bufnr].modified = false

          -- Small delay to ensure LSP attaches and analyzes
          vim.defer_fn(function()
            local diff = create_diff(original_content, current_content, path)
            process_file_with_lsp(bufnr, path, function(result)
              local output = ("File multi-edited: %s\n\n"):format(path)

              -- Add summary of edits
              -- output = output .. ("Applied %d edits:\n"):format(#edits)
              -- for _, edit_result in ipairs(edit_results) do
              --   local replace_info = edit_result.replace_all and " (replace all)" or ""
              --   output = output .. ("  %d. Replace%s: %s -> %s\n"):format(
              --     edit_result.edit_number,
              --     replace_info,
              --     #edit_result.old_string > 50 and (edit_result.old_string:sub(1, 50) .. "...") or edit_result
              --     .old_string,
              --     #edit_result.new_string > 50 and (edit_result.new_string:sub(1, 50) .. "...") or edit_result
              --     .new_string
              --   )
              -- end

              -- output = output .. ("\nDiff:\n%s\n"):format(diff)

              if #result.errors > 0 then
                output = output
                  .. ("\nLSP errors: %d found.\n"):format(#result.errors)
                for _, d in ipairs(result.errors) do
                  output = output
                    .. ("[ERROR] line %d: %s\n"):format(
                      (d.lnum or 0) + 1,
                      d.message
                    )
                end
              else
                output = output .. "No LSP errors found.\n"
              end

              if result.formatted then
                output = output .. "Formatting applied successfully.\n"
              end

              cb({
                status = "success",
                data = {
                  metadata = {
                    file_path = path,
                    exists = true,
                    title = rel_path(path),
                    formatted = result.formatted,
                    diagnostics = result.errors,
                    diff = diff,
                    edits_count = #edits,
                    edits = edit_results,
                  },
                  output = output,
                },
              })
            end)
          end, 100)
        end
      end)
    end,
  },

  opts = { requires_approval = true },
  system_prompt = [[## Multi-Edit File Tool

Performs multiple sequential edits to a single file in one atomic operation, with LSP formatting and analysis.

Usage:
- You MUST use the Read tool at least once in the conversation before multi-editing. This tool will error if you attempt to edit without reading the file.
- When editing text from Read tool output, preserve exact indentation (tabs/spaces) as it appears AFTER the line number prefix. Never include line number prefixes in old_string or new_string.
- This tool is ideal for making several changes to different parts of the same file efficiently.
- All edits are applied sequentially in the order provided - each edit operates on the result of the previous edit.
- The operation is atomic: either all edits succeed or none are applied.
- Only use emojis if explicitly requested by the user.

Critical Requirements:
- All edits must follow the same requirements as the single Edit tool
- Each edit's old_string must be found in the current content (after previous edits)
- Plan edits carefully to avoid conflicts between sequential operations
- Use replace_all for renaming variables or replacing multiple occurrences

The edits array contains objects with:
- old_string: The text to replace (must be unique unless replace_all is true)
- new_string: The text to replace it with
- replace_all: Replace all occurrences (optional, defaults to false)

Warning:
- Since edits are applied sequentially, ensure earlier edits don't affect text that later edits are trying to find
- The tool will fail if any edit's old_string doesn't match exactly (including whitespace)
- After all edits, the file will be formatted via LSP and checked for diagnostics
]],

  schema = {
    type = "function",
    ["function"] = {
      name = "multiedit_file",
      description = "Apply multiple edits to a file sequentially, format via LSP, and return diagnostics.",
      parameters = {
        type = "object",
        properties = {
          file_path = {
            type = "string",
            description = "Absolute path to the file to edit",
          },
          edits = {
            type = "array",
            description = "Array of edit operations to perform sequentially",
            items = {
              type = "object",
              properties = {
                old_string = {
                  type = "string",
                  description = "The text to replace (must be unique unless replace_all is true)",
                },
                new_string = {
                  type = "string",
                  description = "The text to replace it with",
                },
                replace_all = {
                  type = "boolean",
                  description = "Replace all occurrences of old_string (default false)",
                },
              },
              required = { "old_string", "new_string" },
            },
            minItems = 1,
          },
        },
        required = { "file_path", "edits" },
      },
      strict = true,
    },
  },

  function_call = {},
  env = nil,
  handlers = {},
  args = {},
  tool = {},

  output = make_handlers("Multi-Edit File Tool"),

  ["output.prompt"] = function(tool)
    local edits_count = tool.args and tool.args.edits and #tool.args.edits or 0
    local preview = ""
    if tool.args and tool.args.edits then
      for i, edit in ipairs(tool.args.edits) do
        if i > 3 then
          preview = preview
            .. ("  ... and %d more edits\n"):format(edits_count - 3)
          break
        end
        local old_txt = edit.old_string or ""
        local new_txt = edit.new_string or ""
        if #old_txt > 50 then
          old_txt = old_txt:sub(1, 50) .. "..."
        end
        if #new_txt > 50 then
          new_txt = new_txt:sub(1, 50) .. "..."
        end
        local replace_all = edit.replace_all and " (replace all)" or ""
        preview = preview
          .. ("  %d. %s -> %s%s\n"):format(i, old_txt, new_txt, replace_all)
      end
    end
    return ("Multi-edit file: %s\n\nApplying %d edits:\n%s\nFile will be formatted and analysed by LSP."):format(
      tool.args and tool.args.file_path or "",
      edits_count,
      preview
    )
  end,
}

-- Export all three tools
return {
  write_file = {
    description = "Write, format (async), and analyse a file via LSP.",
    callback = WriteFileTool,
  },
  edit_file = {
    description = "Edit a file by replacing text, format (async), and analyse via LSP.",
    callback = EditFileTool,
  },
  multiedit_file = {
    description = "Apply multiple edits to a file sequentially, format (async), and analyse via LSP.",
    callback = MultiEditFileTool,
  },
}
