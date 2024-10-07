vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

local oil = require("oil")

-- Function to toggle the oil preview window
function ToggleOilPreview()
  local is_preview_open = false

  -- Check if there are any windows with the 'oil' preview
  local buffer_count = #vim.fn.getwininfo()
  if buffer_count > 1 then
    is_preview_open = true
  end

  -- Open or close the oil preview based on its current state
  if is_preview_open then
    -- Close the oil preview window

    -- Check if there are any windows with the 'oil' preview
    for _, win in ipairs(vim.fn.getwininfo()) do
      local bufname = vim.fn.bufname(win.bufnr)
      if bufname and not bufname:match("oil") then
        is_preview_open = true
        vim.cmd("bd! " .. win.bufnr)
        break
      end
    end
  else
    -- Open the oil preview window below the current window
    require("oil").open_preview({ split = "belowright" })
    vim.cmd("wincmd h")
  end
end

oil.setup({
  columns = {
    "icon",
    "mtime",
  },
  keymaps = {
    ["<leader>hf"] = {
      "actions.cd",
      opts = { scope = "tab" },
      desc = ":tcd to the current oil directory",
    },
    ["<C-p>"] = function()
      ToggleOilPreview()
    end,
    ["<C-l>"] = false,
    ["<C-w>"] = false,
    ["<C-h>"] = false,
  },
  preview = {
    layout = "right",
    width = 50,
  },
  skip_confirm_for_simple_edits = true,
  view_options = {
    show_hidden = true,
    case_insensitive = true,
    sort = {
      { "name", "asc" },
    },
  },
  float = {
    preview_split = "right",
  },
  git = {
    -- Return true to automatically git add/mv/rm files
    add = function(path)
      return true
    end,
    mv = function(src_path, dest_path)
      return true
    end,
    rm = function(path)
      return true
    end,
  },
})
