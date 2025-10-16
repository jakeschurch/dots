local M = {}

local wrapCommandBySystem = require("utils").wrapCommandBySystem

M.keys = {
	p = {
		description = "power actions",
		keys = {
			l = {
				description = "lock screen",
				action = wrapCommandBySystem({
					Linux = "locker.sh",
					Darwin = "open -a ScreenSaverEngine",
				}),
			},
			p = {
				description = "power off",
				action = wrapCommandBySystem({
					Linux = "sudo poweroff",
					Darwin = "sudo shutdown -h now",
				}),
			},
			r = {
				description = "reboot",
				action = wrapCommandBySystem({
					Linux = "sudo reboot",
					Darwin = "sudo shutdown -r now",
				}),
			},
			s = {
				description = "sleep",
				action = wrapCommandBySystem({
					Linux = "systemctl suspend",
					Darwin = "pmset sleepnow",
				}),
			},
		},
	},
}

return M
