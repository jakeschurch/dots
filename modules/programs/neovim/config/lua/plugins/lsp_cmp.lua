local cmp = require("cmp")
local compare = require("cmp.config.compare")
local types = require("cmp.types")
local luasnip = require("luasnip")
local lspkind = require("lspkind")

vim.g.personal_options = {
  lsp_icons = {
    Array = "󰅪 ",
    Boolean = " ",
    BreakStatement = "󰙧 ",
    Call = "󰃷 ",
    CaseStatement = "󱃙 ",
    Class = " ",
    Color = "󰏘 ",
    Constant = "󰏿 ",
    Constructor = " ",
    ContinueStatement = "→ ",
    Copilot = " ",
    Declaration = "󰙠 ",
    Delete = "󰩺 ",
    DoStatement = "󰑖 ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = "󰈔 ",
    Folder = "󰉋 ",
    ForStatement = "󰑖 ",
    Function = "󰊕 ",
    Identifier = "󰀫 ",
    IfStatement = "󰇉 ",
    Interface = " ",
    Key = "󰌋 ",
    Keyword = "󰌋 ",
    List = "󰅪 ",
    Log = "󰦪 ",
    Lsp = " ",
    Macro = "󰁌 ",
    MarkdownH1 = "󰉫 ",
    MarkdownH2 = "󰉬 ",
    MarkdownH3 = "󰉭 ",
    MarkdownH4 = "󰉮 ",
    MarkdownH5 = "󰉯 ",
    MarkdownH6 = "󰉰 ",
    Method = "󰆧 ",
    Module = "󰏗 ",
    Namespace = "󰅩 ",
    Null = "󰢤 ",
    Number = "󰎠 ",
    Object = "󰅩 ",
    Operator = "󰆕 ",
    Package = "󰆦 ",
    Property = " ",
    Reference = "󰦾 ",
    Regex = " ",
    Repeat = "󰑖 ",
    Scope = "󰅩 ",
    Snippet = "󰩫 ",
    Specifier = "󰦪 ",
    Statement = "󰅩 ",
    String = "󰉾 ",
    Struct = " ",
    SwitchStatement = "󰺟 ",
    Terminal = " ",
    Text = " ",
    Type = " ",
    TypeParameter = "󰆩 ",
    Unit = " ",
    Value = "󰎠 ",
    Variable = "󰀫 ",
    WhileStatement = "󰑖 ",
  },
}

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0
    and vim.api
        .nvim_buf_get_lines(0, line - 1, line, true)[1]
        :sub(col, col)
        :match("%s")
      == nil
end

---@type table<integer, integer>
local modified_priority = {
  [types.lsp.CompletionItemKind.Variable] = types.lsp.CompletionItemKind.Method,
  [types.lsp.CompletionItemKind.Snippet] = 0, -- top
  [types.lsp.CompletionItemKind.Keyword] = 0, -- top
  [types.lsp.CompletionItemKind.Text] = 100, -- bottom
}
---@param kind integer: kind of completion entry
local function modified_kind(kind)
  return modified_priority[kind] or kind
end

cmp.setup({
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = lspkind.cmp_format({
      mode = "symbol", -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      -- can also be a function to dynamically calculate max width such as
      -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
      ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default
      -- the function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        return vim_item
      end,
    }),
    --   vim_item.menu = ({
    --     nvim_lsp = "[LSP]",
    --     luasnip = "[Snip]",
    --     buffer = "[Buff]",
    --     path = "[Path]",
    --     dictionary = "[Text]",
    --     spell = "[Spll]",
    --     calc = "[Calc]",
    --   })[entry.source.name]
    --   return vim_item
    -- end,
  },
  sorting = {
    -- https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
    comparators = {
      compare.offset,
      compare.exact,
      function(entry1, entry2) -- sort by length ignoring "=~"
        local len1 =
          string.len(string.gsub(entry1.completion_item.label, "[=~()_]", ""))
        local len2 =
          string.len(string.gsub(entry2.completion_item.label, "[=~()_]", ""))
        if len1 ~= len2 then
          return len1 - len2 < 0
        end
      end,
      compare.recently_used,
      function(entry1, entry2) -- sort by compare kind (Variable, Function etc)
        local kind1 = modified_kind(entry1:get_kind())
        local kind2 = modified_kind(entry2:get_kind())
        if kind1 ~= kind2 then
          return kind1 - kind2 < 0
        end
      end,
      function(entry1, entry2) -- score by lsp, if available
        local t1 = entry1.completion_item.sortText
        local t2 = entry2.completion_item.sortText
        if t1 ~= nil and t2 ~= nil and t1 ~= t2 then
          return t1 < t2
        end
      end,
      compare.score,
      compare.order,
    },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-c>"] = cmp.mapping.abort(),

    ["<C-Space>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

    ["<C-p>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-n>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  experimental = {
    ghost_text = true,
  },
  completion = {
    keyword_length = 2,
    completeopt = "menu,noselect",
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" }, -- For luasnip users.
    { name = "treesitter" },
    -- { name = "rg", keyword_length = 4 },
    { name = "emoji", insert = true },
    -- { name = "buffer", keyword_length = 3 },
    -- { name = "path" },
  }),
  performance = {
    debounce = 10, -- default is 60ms
    throttle = 10, -- default is 30ms
    max_entries = 3,
  },
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
    { name = "path" },
    { name = "emoji" },
  }, {
    { name = "buffer" },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ ":" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
    { name = "buffer" },
    { name = "cmdline" },
  },
  matching = { disallow_symbol_nonprefix_matching = false },
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

require("luasnip").config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})
require("luasnip.loaders.from_vscode").lazy_load()
require("luasnip.loaders.from_snipmate").lazy_load({ paths = { "./snippets" } })

-- autopairs
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
