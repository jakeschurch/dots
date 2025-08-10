local Modal = require("modal")

local recursiveBind = require("recursiveBind").recursiveBind

local appKeyBinds = require("keymaps.apps").keys
local powermenuKeyBinds = require("keymaps.powermenu").keys
local wmKeys = require("screens").keys

recursiveBind(wmKeys)

local modalBindings = Modal.aggregateBindings(appKeyBinds, powermenuKeyBinds)

local modal = Modal.new(hs, "m", modalBindings, "cmd")
modal:bind()
