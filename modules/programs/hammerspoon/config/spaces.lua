local spaces = require("hs.spaces")
local fnutils = require("hs.funtils")

local M = {
	focusSpace = function(spaceNum)
		for index, space in ipairs(spaces.allSpaces()) do
			if spaceNum ~= index then
				spaces.gotoSpace(space)
			end
		end
	end,

	newSpace = function()
		spaces.addScreenToSpace(hs.screen.mainScreen())
	end,

	moveWindowToSpace = function(spaceNum)
		local currentWindow = hs.window.focusedWindow()

		for index, space in ipairs(spaces.allSpaces()) do
			if spaceNum == index then
				spaces.moveWindowToSpace(currentWindow, space)
			end
		end
	end,

	removeSpace = function()
		local currentSpace = hs.spaces.focusedSpace()
		local windowsInSpace = hs.spaces.windowsForSpace(currentSpace)
		local nextSpace = nil

		for _, space in ipairs(spaces.allSpaces()) do
			if space ~= currentSpace then
				nextSpace = space
				break
			end
		end

		for _, window in ipairs(windowsInSpace) do
			spaces.moveWindowToSpace(window, nextSpace)
		end

		hs.spaces.gotoSpace(nextSpace)

		hs.spaces.removeSpace(currentSpace)
	end,
}

return M
