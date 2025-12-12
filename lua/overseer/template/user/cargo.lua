local tmpl_cargo = function()
	return {
		-- 任务1：带额外参数的cargo build
		{
			name = "cargo build (with additional flags)",
			params = {
				args = {
					type = "list",
					subtype = { type = "string" },
					delimiter = " ",
					name = "Additional Flags",
					desc = "Additional flags for cargo build",
					default = {},
				},
			},
			builder = function(params)
				return {
					cmd = { "cargo" },
					args = vim.list_extend({ "build" }, params.args),
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
		-- 任务2：基本的cargo build
		{
			name = "cargo build",
			builder = function()
				return {
					cmd = { "cargo" },
					args = { "build" },
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
		-- 任务3：带额外参数的cargo run
		{
			name = "cargo run (with additional flags)",
			params = {
				args = {
					type = "list",
					subtype = { type = "string" },
					delimiter = " ",
					name = "Additional Flags",
					desc = "Additional flags for cargo run",
					default = {},
				},
			},
			builder = function(params)
				return {
					cmd = { "cargo" },
					args = vim.list_extend({ "run" }, params.args),
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
		-- 任务4：基本的cargo run
		{
			name = "cargo run",
			builder = function()
				return {
					cmd = { "cargo" },
					args = { "run" },
					cwd = vim.fn.getcwd(),
					components = { "open_output", "default" },
				}
			end,
		},
	}
end

return {
	-- 缓存键：使用当前工作目录
	cached_key = function(opts)
		return vim.fn.getcwd()
	end,

	-- 条件检测
	condition = {
		callback = function(search)
			-- 检查当前目录下是否有Cargo.toml文件
			local has_cargo_toml = vim.loop.fs_stat(vim.fn.getcwd() .. "/Cargo.toml") ~= nil
			-- 检查cargo命令是否可用
			local has_cargo = vim.fn.executable("cargo") == 1

			if not has_cargo_toml then
				return false, "No Cargo.toml found in current directory"
			elseif not has_cargo then
				return false, "No cargo available"
			else
				return true
			end
		end,
	},

	-- 任务生成器
	generator = function(search, cb)
		cb(tmpl_cargo())
	end,
}
