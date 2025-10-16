local M = {}

M.executeCommand = function(command)
	local output, status = hs.execute(command)
	return output:match("^%s*(.-)%s*$"), status -- Trim whitespace (newlines)
end

M.getSystem = function()
	return M.executeCommand("uname -s")
end

M.wrap = function(lambda, args)
	return function()
		if args then
			return lambda(args)
		else
			lambda()
		end
	end
end

M.wrapCommand = function(command)
	return M.wrap(M.executeCommand, command)
end

M.wrapCommandBySystem = function(lookupTable)
	return M.wrapCommand(lookupTable[M.getSystem()])
end

return M
