local ls = require("luasnip")

vim.keymap.set({ "i", "s" }, "<C-J>", function()
  ls.jump(1)
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-K>", function()
  ls.jump(-1)
end, { silent = true })

local s = ls.snippet
local t = ls.text_node
local f = ls.function_node

local function gen_date_snippets()
  local snippets = {}
  local target_dates = {
    "yesterday",
    "today",
    "tomorrow",
    "next monday",
    "next tuesday",
    "next wednesday",
    "next thursday",
    "next friday",
    "next week",
    "next month",
    "last monday",
    "last tuesday",
    "last wednesday",
    "last thursday",
    "last friday",
    "last week",
    "last month",
  }

  for _, target_date in pairs(target_dates) do
    table.insert(
      snippets,
      s(
        { trig = "@" .. target_date:gsub(" ", "-"), snippetType = "autosnippet" },
        {
          t(""),
          f(function(_, _, _)
            return vim.fn.trim(
              vim.fn.system([[date -d ']] .. target_date .. [[' +'%Y-%m-%d']])
            )
          end, {}),
        }
      )
    )
  end

  return snippets
end

-- Snippets
ls.add_snippets("all", gen_date_snippets())
