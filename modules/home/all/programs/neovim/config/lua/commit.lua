vim.api.nvim_create_user_command("Commit", function(opts)
	local commit_message = opts.args
	vim.fn.system("fg-commit-wrapper " .. commit_message)
end, { nargs = "*" })
