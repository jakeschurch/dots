require("headlines").setup({
	["vimwiki.markdown"] = {
		treesitter_language = "markdown",
		headline_highlights = { "Headline1", "Headline2", "Headline3", "Headline4", "Headline5", "Headline6" },
	},
	vimwiki = {
		treesitter_language = "markdown",
		headline_highlights = true,
	},
})
