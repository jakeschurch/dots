-- GitHub/Obsidian callouts.
--
-- Two ways in, because bare keywords cannot be autosnippet triggers: an
-- autosnippet fires the moment its trigger matches, so `note` would rewrite
-- "Notes from standup" into "> [!NOTE]s from standup" before the second word
-- was typed. The `!` prefix mirrors the callout syntax and cannot collide with
-- prose; the bare keyword stays available through the completion menu, where
-- accepting it is deliberate.

local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local line_begin = require("luasnip.extras.conditions.expand").line_begin

local keywords = {
  "NOTE",
  "TIP",
  "IMPORTANT",
  "WARNING",
  "CAUTION",
  "ABSTRACT",
  "SUMMARY",
  "TLDR",
  "INFO",
  "TODO",
  "HINT",
  "SUCCESS",
  "CHECK",
  "DONE",
  "QUESTION",
  "HELP",
  "FAQ",
  "ATTENTION",
  "FAILURE",
  "FAIL",
  "MISSING",
  "DANGER",
  "ERROR",
  "BUG",
  "EXAMPLE",
  "QUOTE",
  "CITE",
}

local snippets = {}

for _, keyword in ipairs(keywords) do
  local callout = "> [!" .. keyword .. "]"

  -- Expands as you type: `!note` / `!NOTE` at the start of a line.
  for _, trigger in ipairs({ "!" .. keyword:lower(), "!" .. keyword }) do
    table.insert(
      snippets,
      s({
        trig = trigger,
        wordTrig = false,
        snippetType = "autosnippet",
        condition = line_begin,
      }, { t(callout) })
    )
  end

  -- Offered in the completion menu on the bare keyword.
  table.insert(
    snippets,
    s({
      trig = keyword:lower(),
      wordTrig = true,
      desc = callout,
    }, { t(callout) })
  )
end

ls.add_snippets("markdown", snippets)
ls.add_snippets("vimwiki", snippets)
