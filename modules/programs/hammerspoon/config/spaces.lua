local function execYabai(args)
	local command = string.format("/etc/static/profiles/per-user/jake/bin/yabai %s", args)
	print(string.format("yabai: %s", command))
	os.execute(command)
end

-- throw/focus monitors
local targets = {
	-- x = "recent",
	N = "prev",
	n = "next",
}
for key, target in pairs(targets) do
	hs.hotkey.bind({ "ctrl", "alt" }, key, function()
		execYabai(string.format("-m display --focus %s", target))
	end)
	hs.hotkey.bind({ "ctrl", "cmd" }, key, function()
		execYabai(string.format("-m window --display %s", target))
		execYabai(string.format("-m display --focus %s", target))
	end)
end
-- numbered monitors
for i = 1, 5 do
	hs.hotkey.bind({ "cmd" }, tostring(i), function()
		execYabai(string.format("-m display --focus %s", i))
	end)
	hs.hotkey.bind({ "cmd", "shift" }, tostring(i), function()
		execYabai(string.format("-m window --display %s", i))
		execYabai(string.format("-m display --focus %s", i))
	end)
end

return {
	execYabai = execYabai,
}
