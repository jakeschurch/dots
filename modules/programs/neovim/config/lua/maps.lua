-- window movements
vim.keymap.set("n", "<C-q>", "<C-w>q")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- better command defaults
vim.keymap.set("n", "!", ":!")

-- save whole line in buffer
vim.keymap.set("n", "Y", "^y$")

-- quick save
vim.keymap.set("n", "W", ":wa!<cr>")

-- change pwd to file dir
vim.keymap.set("n", "<leader>hf", ":lcd %:p:h<cr>")

vim.keymap.set("n", "J", "mzJ`z")

-- pgdn
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- pgup
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

function ToggleQuickFix()
  local qf_exists = false
  -- Check if the quickfix window is open
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      qf_exists = true
      break
    end
  end

  if qf_exists then
    vim.cmd("cclose")
  else
    vim.cmd("copen")
  end
end

-- Optionally, map this function to a keybinding, e.g., <leader>q
vim.api.nvim_set_keymap(
  "n",
  "<leader>q",
  ":lua ToggleQuickFix()<CR>",
  { noremap = true, silent = true }
)

vim.cmd([[
cnoremap %s/ %s/\v
cnoremap s/ s/\v

cnoreabbrev c G c
cnoreabbrev a G add %
]])

-- Define a function to toggle booleans
function ToggleBoolean()
  -- Get the word under the cursor
  local word = vim.fn.expand("<cword>")

  -- Define boolean mappings
  local booleans = {
    ["true"] = "false",
    ["false"] = "true",
    ["on"] = "off",
    ["off"] = "on",
    ["yes"] = "no",
    ["no"] = "yes",
  }

  -- If the word is a known boolean, replace it with its opposite
  if booleans[word] then
    vim.cmd("normal! ciw" .. booleans[word])
  else
    print("No boolean to toggle")
  end
end

-- Map <C-X> in normal mode to call the ToggleBoolean function
vim.api.nvim_set_keymap(
  "n",
  "<C-X>",
  ":lua ToggleBoolean()<CR>",
  { noremap = true, silent = true }
)

function ToggleLocationList()
  local loclist_exists = false
  -- Check if the location list is open for the current window
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.loclist == 1 and win.winid == vim.api.nvim_get_current_win() then
      loclist_exists = true
      break
    end
  end

  if loclist_exists then
    vim.cmd("lclose")
  else
    vim.cmd("lopen")
  end
end

-- Optionally, map this function to a keybinding, e.g., <leader>l
vim.api.nvim_set_keymap(
  "n",
  "<leader>l",
  ":lua ToggleLocationList()<CR>",
  { noremap = true, silent = true }
)

-- Smart paste in insert mode (adjusts indentation after pasting)
function SmartPasteInsert()
  -- Turn off 'paste' mode to respect indentation settings
  vim.opt.paste = false
  -- Use normal mode commands to re-indent the last pasted block
  vim.cmd("normal! `[v`]=")
end

-- Smart paste in normal mode (adjusts indentation after pasting)
function SmartPasteNormal()
  -- Turn off 'paste' mode to respect indentation settings
  vim.opt.paste = false
  -- Use visual selection to re-indent the pasted block
  vim.cmd("normal! `[v`]=")
end

-- -- Key mappings for smart pasting
-- -- In insert mode, use <C-r> to paste with automatic indentation
-- vim.api.nvim_set_keymap(
--   "i",
--   "<C-r>",
--   "<C-o>:lua SmartPasteInsert()<CR>",
--   { noremap = true, silent = true }
-- )

-- In normal mode, use p to paste with automatic indentation
-- vim.api.nvim_set_keymap(
--   "n",
--   "p",
--   "p:lua SmartPasteNormal()<CR>",
--   { noremap = true, silent = true }
-- )
--
-- vim.api.nvim_set_keymap(
--   "n",
--   "P",
--   "P:lua SmartPasteNormal()<CR>",
--   { noremap = true, silent = true }
-- )
