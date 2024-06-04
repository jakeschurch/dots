vim.treesitter.language.register("markdown", "vimwiki")

local g = vim.g

g.vimwiki_folding = "list"
g.automatic_nested_syntaxes = 1
-- g.vimwiki_filetypes = { "markdown" }
-- g.vimwiki_sync_branch = "main"
-- g.vimwiki_ext = "markdown"

local syntax = "markdown"
local syntax_ext = ".md"

g.vimwiki_list = {
	{ path = "~/Documents/wiki/personal", syntax = syntax, ext = syntax_ext },
	{ path = "~/Documents/wiki/engineering", syntax = syntax, ext = syntax_ext },
	{ path = "~/Documents/wiki/ventures", syntax = syntax, ext = syntax_ext },
	{ path = "~/Documents/wiki/work", syntax = syntax, ext = syntax_ext },
	{ path = "~/Documents/wiki/work/fieldguide", syntax = syntax, ext = syntax_ext },
	{ path = "~/Documents/wiki/books", syntax = syntax, ext = syntax_ext },
}
