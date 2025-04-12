local M = {}

function M.input_args()
	local argument_string = vim.fn.input("Program arg(s) (enter nothing to leave it null): ")
	return vim.fn.split(argument_string, " ", true)
end

function M.input_exec_path()
	return vim.fn.input('Path to executable (default to "a.out"): ', vim.fn.expand("%:p:h") .. "/a.out", "file")
end

function M.input_file_path()
	return vim.fn.input("Path to debuggee (default to the current file): ", vim.fn.expand("%:p"), "file")
end

function M.get_env()
	local variables = {}
	for k, v in pairs(vim.fn.environ()) do
		table.insert(variables, string.format("%s=%s", k, v))
	end
	return variables
end

local dap = require("dap")

dap.adapters.codelldb = {
	type = "server",
	port = "${port}",
	executable = {
		-- Change this to your path!
		command = "/opt/codelldb/adapter/codelldb",
		args = { "--port", "${port}" },
	},
}

dap.configurations.rust = {
	{
		name = "npulearn",
		type = "codelldb",
		request = "launch",
		-- program = function()
		-- 	return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		-- end,
		program = "{workspaceFolder}/src-tauri/target/debug/npulearn",
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

local function load_launchjs()
	local launch_file = vim.fn.getcwd() .. "/.vscode/launch.json"
	if vim.fn.filereadable(launch_file) == 1 then
		local content = vim.fn.readfile(launch_file)
		local json = vim.fn.json_decode(table.concat(content, "\n"))
		for _, config in pairs(json.configurations) do
			dap.configurations[config.type] = dap.configurations[config.type] or {}
			table.insert(dap.configurations[config.type], config)
		end
	end
end

-- 加载 launch.json
load_launchjs()

-- 可选：调试 UI 配置
require("dapui").setup()

return setmetatable({}, {
	__index = function(_, key)
		return function()
			return function()
				return M[key]()
			end
		end
	end,
})
