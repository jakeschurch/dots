-- TODO:
local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
	[[:::::::::    ::::::::      ::::     ::::   ########   :::::::::   ::::::::::]],
	[[:+:    :+:  :+:    :+:     +:+:+: :+:+:+  :+:    :+:  :+:    :+:  :+:]],
	[[+:+    +:+  +:+    +:+     +:+ +:+:+ +:+  +:+    +:+  +:+    +:+  +:+]],
	[[+#+    +:+  +#+    +:+     +#+  +:+  +#+  +#+    +#+  +#++:++#:   +#++:++#]],
	[[+#+    +:+  +#+    +#+     +#+       +#+  +#+    +#+  +#+    +#+  +#+]],
	[[#+#    #+#  #+#    #+#     #+#       #+#  #+#    #+#  #+#    #+#  #+#]],
	[[#########    ########      ###       ###   ########   ###    ###  ##########]],
}

dashboard.section.buttons.val = {
	dashboard.button("l", "  Load last session", ":SessionLoadLast<CR>"),
	dashboard.button("s", "  Select sessions", ":Telescope persisted<CR>"),
	dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
	dashboard.button("e", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
	dashboard.button("t", "  Find text", ":Telescope live_grep <CR>"),
	-- dashboard.button("c", "  Configuration", ":e <CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa<CR>"),
}

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"
dashboard.opts.opts.noautocmd = true

alpha.setup(dashboard.opts)
