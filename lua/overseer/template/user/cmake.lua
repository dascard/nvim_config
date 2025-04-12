local tmpl_cmake = function()
	return {
		{
			name = "cmake build (with additional flags)",
			params = {
				args = {
					type = "list",
					subtype = { type = "string" },
					delimiter = " ",
					name = "Additional Flags",
					desc = "Additional flags for cmake",
					default = {},
				},
			},
			builder = function(params)
				return {
					cmd = { "cmake" },
					args = vim.list_extend({ "-B", "build", "-S", "." }, params.args),
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
		{
			name = "cmake build",
			builder = function()
				return {
					cmd = { "cmake" },
					args = { "-B", "build", "-S", "." },
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
		{
			name = "cmake run (with additional flags)",
			params = {
				args = {
					type = "list",
					subtype = { type = "string" },
					delimiter = " ",
					name = "Additional Flags",
					desc = "Additional flags for cmake",
					default = {},
				},
			},
			builder = function(params)
				return {
					cmd = { "cmake" },
					args = vim.list_extend({ "-B", "build", "-S", "." }, params.args),
					cwd = vim.fn.getcwd(),
					components = {
						"open_output",
						"default",
						{ "run_after", task_names = { { cmd = "make", cwd = "build" } } },
					},
				}
			end,
		},
		{
			name = "cmake run",
			builder = function()
				return {
					cmd = { "cmake" },
					args = { "-B", "build", "-S", "." },
					cwd = vim.fn.getcwd(),
					components = {
						"open_output",
						"default",
						{ "run_after", task_names = { { cmd = "make", cwd = "build" } } },
					},
				}
			end,
		},
	}
end

vim.fn.mkdir("build", "p")

return {
	cached_key = function(opts)
		return vim.fn.getcwd()
	end,

	condition = {
		callback = function(search)
			-- 检查当前工作目录下是否存在CMakeLists.txt文件
			local has_cmakelists = vim.loop.fs_stat(vim.fn.getcwd() .. "/CMakeLists.txt") ~= nil
			-- 检查cmake命令是否可用
			local has_cmake = vim.fn.executable("cmake") == 1

			-- 如果没有CMakeLists.txt文件，返回false并提示错误
			if not has_cmakelists then
				return false, "No CMakeLists.txt found in current directory"
			-- 如果cmake命令不可用，返回false并提示错误
			elseif not has_cmake then
				return false, "No cmake available"
			-- 条件都满足，返回true
			else
				return true
			end
		end,
	},

	generator = function(search, cb)
		cb(tmpl_cmake())
	end,
}
