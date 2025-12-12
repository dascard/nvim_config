return {
	name = "Run script",
	builder = function()
		local file = vim.fn.expand("%:p")
		local cmd = { file }
		if vim.bo.filetype == "go" then
			cmd = { "go", "run", file }
		elseif vim.bo.filetype == "python" then
			cmd = { "python", file }
		elseif vim.bo.filetype == "js" then
			cmd = { "node", file }
		end
		return {
			cmd = cmd,
			components = {
				"open_output",
				"default",
			},
		}
	end,
	condition = {
		filetype = { "go", "python", "js", "sh" },
	},
}
