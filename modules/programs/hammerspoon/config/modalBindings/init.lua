local Modal = require("modal")

local powermenuBindings = require("modalBindings.powermenu")
local appmenuBindings = require("modalBindings.appset")

local powerModal = Modal.new(hs, "p", powermenuBindings, "cmd")
local appBindings = Modal.new(hs, "o", appmenuBindings, "cmd")

powerModal:bind()
appBindings:bind()
