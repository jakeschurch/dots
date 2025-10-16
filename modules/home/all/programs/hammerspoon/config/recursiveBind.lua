local M = {}

M._buildRecursiveMappings = function(mappings, modifier)
	local bindings = {}

	for k, v in pairs(mappings) do
		if v.action then
			table.insert(bindings, {
				modifier = modifier,
				key = k,
				action = v.action,
			})
		elseif v.keys then
			local subMenuBindings = M._buildRecursiveMappings(v.keys, { table.unpack(modifier), k })

			for _, subBinding in ipairs(subMenuBindings) do
				table.insert(bindings, subBinding)
			end
		end
	end

	return bindings
end

M.recursiveBind = function(bindings)
	for _, binding in ipairs(M._buildRecursiveMappings(bindings, { "cmd" })) do
		-- Properly bind the hotkeys
		hs.hotkey.bind(binding.modifier, binding.key, binding.action)
	end
end

return M
