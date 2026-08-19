local lualine = require("lualine")
local pills = require("domain.ui.pills")
local ignored_filetypes = require("lib.utils").ignored_filetypes

local c = pills.colors

local function diff_source()
  local gitsigns = vim.b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

-- Only the pills carry a fill; the gaps take the buffer's own background so the
-- capsules read as floating rather than sitting on a solid bar. `bg = "NONE"`
-- would instead fall through to the theme's StatusLine highlight, which *is* a
-- solid bar on an opaque terminal.
local bar = pills.bar_bg()

-- lualine only paints the regions it draws; the rest of the bar (and the `%=`
-- fill) uses StatusLine, so that has to match too. Re-applied on ColorScheme
-- because loading a scheme resets these to its own solid bar, which leaves the
-- pill caps visible against it instead of blending into the buffer.
local function set_bar_highlights()
  for _, group in ipairs({ "StatusLine", "StatusLineNC", "WinBar", "WinBarNC" }) do
    vim.api.nvim_set_hl(0, group, { bg = bar, fg = c.fg4 })
  end
end

set_bar_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("lualine-pills", { clear = true }),
  callback = set_bar_highlights,
  desc = "Keep the statusline transparent behind the pills",
})

local empty = { bg = bar, fg = c.fg4 }
local transparent = {}
for _, mode in ipairs({
  "normal",
  "insert",
  "visual",
  "replace",
  "command",
  "terminal",
  "inactive",
}) do
  transparent[mode] =
    { a = empty, b = empty, c = empty, x = empty, y = empty, z = empty }
end

-- Each pill is its own component with round caps. lualine draws the cap glyph
-- in the component's own colour, which is exactly the effect we want.
local cap = { left = pills.cap.left, right = pills.cap.right }

---@param spec table lualine component spec
---@param fill string pill background
---@param fg? string pill foreground (defaults to the dark base, for contrast)
local function pill(spec, fill, fg)
  return vim.tbl_extend("keep", {
    separator = cap,
    padding = { left = 1, right = 1 },
    color = { bg = fill, fg = fg or c.bg0, gui = "bold" },
  }, spec)
end

-- A transparent spacer so adjacent pills don't touch. It carries the same
-- `cond` as the pill it precedes, so hidden pills don't leave a double gap.
---@param cond? fun():boolean
local function gap(cond)
  return {
    function()
      return " "
    end,
    cond = cond,
    padding = 0,
    separator = "",
    color = { bg = bar, fg = bar },
  }
end

--- Interleave spacers between pills, preserving each pill's `cond`.
---@param components table[]
local function spaced(components)
  local out = {}
  for i, component in ipairs(components) do
    if i > 1 then
      table.insert(out, gap(component.cond))
    end
    table.insert(out, component)
  end
  return out
end

local severities = {
  error = { icon = "󱍷", color = c.red },
  warn = { icon = "󰀪", color = c.yellow },
  info = { icon = "󰋽", color = c.blue },
  hint = { icon = "󰌶", color = c.aqua },
}

--- One pill per severity, hidden when the count is zero — matching the
--- separate warn/hint capsules in the reference screenshot.
local function diagnostic_pill(name)
  local severity = severities[name]
  return pill({
    "diagnostics",
    sources = { "nvim_diagnostic" },
    sections = { name },
    symbols = { [name] = severity.icon .. " " },
    colored = false,
    cond = function()
      local level = vim.diagnostic.severity[name:upper()]
      return #vim.diagnostic.get(0, { severity = level }) > 0
    end,
  }, severity.color)
end

lualine.setup({
  options = {
    theme = transparent,
    icons_enabled = true,
    globalstatus = true,
    -- Only the winbar is disabled per-filetype. globalstatus means there is
    -- exactly one statusline that cannot be hidden, so listing filetypes here
    -- would blank it out rather than remove it — a bare bar in oil/fugitive
    -- instead of the pills.
    disabled_filetypes = { winbar = ignored_filetypes },
    always_show_tabline = false,
    -- The pills supply their own edges; lualine must not draw any of its own.
    component_separators = "",
    section_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = spaced({
      pill({
        "mode",
        fmt = function(str)
          return str:sub(1, 3)
        end,
      }, c.bg3, c.fg1),
    }),
    lualine_b = spaced({
      pill({
        "branch",
        fmt = function(str)
          local short_prefix = str:gsub("%a+/", "")
          if string.len(short_prefix) > 15 then
            return short_prefix:sub(1, 15) .. " ..."
          else
            return short_prefix
          end
        end,
      }, c.bg2, c.fg1),
      pill({
        "diff",
        source = diff_source,
        colored = false,
        cond = function()
          local d = diff_source()
          return d ~= nil
            and ((d.added or 0) + (d.modified or 0) + (d.removed or 0)) > 0
        end,
      }, c.bg2, c.fg1),
    }),
    lualine_c = spaced({
      diagnostic_pill("error"),
      diagnostic_pill("warn"),
      diagnostic_pill("info"),
      diagnostic_pill("hint"),
    }),
    lualine_x = spaced({
      pill({
        "searchcount",
        cond = function()
          return vim.v.hlsearch == 1
        end,
      }, c.orange),
    }),
    lualine_y = spaced({
      pill({ "filetype" }, c.bg2, c.fg1),
      pill({ "os.date('%d-%b %H:%M')" }, c.bg1, c.fg4),
    }),
    lualine_z = spaced({
      pill({ "location" }, c.bg2, c.fg1),
      pill({
        function()
          local line = vim.fn.line(".")
          local total = vim.fn.line("$")
          return string.format(
            "󰉸 %d%%%% / %d",
            math.floor(line / total * 100),
            total
          )
        end,
      }, c.bg3, c.fg1),
    }),
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = spaced({
      pill({ "filename", path = 1 }, c.bg1, c.fg4),
    }),
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
})
