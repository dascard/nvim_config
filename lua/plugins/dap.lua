local colors = {
	rosewater = "#DC8A78",
	flamingo = "#DD7878",
	mauve = "#CBA6F7",
	pink = "#F5C2E7",
	red = "#E95678",
	maroon = "#B33076",
	peach = "#FF8700",
	yellow = "#F7BB3B",
	green = "#AFD700",
	sapphire = "#36D0E0",
	blue = "#61AFEF",
	sky = "#04A5E5",
	teal = "#B5E8E0",
	lavender = "#7287FD",

	text = "#F2F2BF",
	subtext1 = "#BAC2DE",
	subtext0 = "#A6ADC8",
	overlay2 = "#C3BAC6",
	overlay1 = "#988BA2",
	overlay0 = "#6E6B6B",
	surface2 = "#6E6C7E",
	surface1 = "#575268",
	surface0 = "#302D41",

	base = "#1D1536",
	mantle = "#1C1C19",
	crust = "#161320",
}
local icons = {
	ui = require("utils.icons").get("ui"),
	dap = require("utils.icons").get("dap"),
}
vim.api.nvim_set_hl(0, "DapStopped", { fg = colors.green, bg = colors.peach })
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = colors.red })

vim.fn.sign_define("DapBreakpoint", { text = icons.dap.Breakpoint, texthl = "DapBreakpoint", linehl = "", numhl = "" })
vim.fn.sign_define(
	"DapBreakpointCondition",
	{ text = icons.dap.BreakpointCondition, texthl = "DapBreakpoint", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapStopped", { text = icons.dap.Stopped, texthl = "DapStopped", linehl = "", numhl = "" })
vim.fn.sign_define(
	"DapBreakpointRejected",
	{ text = icons.dap.BreakpointRejected, texthl = "DapBreakpoint", linehl = "", numhl = "" }
)
vim.fn.sign_define("DapLogPoint", { text = icons.dap.LogPoint, texthl = "DapLogPoint", linehl = "", numhl = "" })

return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		optional = true,
		config = function()
			local dap = require("dap")
			
			-- ========== C/C++ 配置 ==========
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.expand("~/.local/share/nvim/mason/bin/codelldb"),
					args = { "--port", "${port}" },
				},
			}

			dap.configurations.c = {
				{
					name = "Launch C Program",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
				{
					name = "Launch C Program with Args",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
					runInTerminal = false,
				},
				{
					name = "Attach to Process",
					type = "codelldb",
					request = "attach",
					pid = function()
						return tonumber(vim.fn.input("Process ID: "))
					end,
					cwd = "${workspaceFolder}",
				},
			}

			-- C++ 使用相同的配置
			dap.configurations.cpp = dap.configurations.c

			-- ========== Rust 配置 ==========
			dap.configurations.rust = {
				{
					name = "Launch Rust Binary",
					type = "codelldb",
					request = "launch",
					program = function()
						-- 尝试自动找到最新的可执行文件
						local target_dir = vim.fn.getcwd() .. "/target/debug"
						if vim.fn.isdirectory(target_dir) == 1 then
							local binaries = vim.fn.glob(target_dir .. "/*", false, true)
							for _, binary in ipairs(binaries) do
								if vim.fn.executable(binary) == 1 then
									return binary
								end
							end
						end
						return vim.fn.input("Path to executable: ", target_dir .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
					runInTerminal = false,
				},
				{
					name = "Launch Rust Binary with Args",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
					runInTerminal = false,
				},
				{
					name = "Launch Rust Tests",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to test executable: ", vim.fn.getcwd() .. "/target/debug/deps/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = { "--nocapture" },
					runInTerminal = false,
				},
			}

			-- ========== Python 配置 ==========
			dap.adapters.python = function(cb, config)
				if config.request == "attach" then
					---@diagnostic disable-next-line: undefined-field
					local port = (config.connect or config).port
					---@diagnostic disable-next-line: undefined-field
					local host = (config.connect or config).host or "127.0.0.1"
					cb({
						type = "server",
						port = assert(port, "`connect.port` is required for a python `attach` configuration"),
						host = host,
						options = {
							source_filetype = "python",
						},
					})
				else
					cb({
						type = "executable",
						command = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python"),
						args = { "-m", "debugpy.adapter" },
						options = {
							source_filetype = "python",
						},
					})
				end
			end

			dap.configurations.python = {
				{
					name = "Launch Current File",
					type = "python",
					request = "launch",
					program = "${file}",
					console = "integratedTerminal",
					cwd = "${workspaceFolder}",
					args = {},
				},
				{
					name = "Launch Current File with Args",
					type = "python",
					request = "launch",
					program = "${file}",
					console = "integratedTerminal",
					cwd = "${workspaceFolder}",
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
				},
				{
					name = "Launch Module",
					type = "python",
					request = "launch",
					module = function()
						return vim.fn.input("Module name: ")
					end,
					console = "integratedTerminal",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Launch Django",
					type = "python",
					request = "launch",
					program = "${workspaceFolder}/manage.py",
					args = { "runserver", "0.0.0.0:8000" },
					console = "integratedTerminal",
					cwd = "${workspaceFolder}",
					django = true,
				},
				{
					name = "Launch Flask",
					type = "python",
					request = "launch",
					module = "flask",
					env = {
						FLASK_APP = function()
							return vim.fn.input("Flask app: ", "app.py")
						end,
						FLASK_ENV = "development",
					},
					args = { "run", "--debug" },
					console = "integratedTerminal",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Python: Remote Attach",
					type = "python",
					request = "attach",
					connect = {
						host = function()
							return vim.fn.input("Host: ", "localhost")
						end,
						port = function()
							return tonumber(vim.fn.input("Port: ", "5678"))
						end,
					},
				},
			}

			-- ========== Node.js/JavaScript/TypeScript 配置 ==========
			dap.adapters.node2 = {
				type = "executable",
				command = "node",
				args = { vim.fn.expand("~/.local/share/nvim/mason/packages/node-debug2-adapter/out/src/nodeDebug.js") },
			}

			dap.configurations.javascript = {
				{
					name = "Launch Node.js",
					type = "node2",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					name = "Launch Node.js with Args",
					type = "node2",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
					sourceMaps = true,
					protocol = "inspector",
					console = "integratedTerminal",
				},
				{
					name = "Attach to Node.js",
					type = "node2",
					request = "attach",
					processId = function()
						return tonumber(vim.fn.input("Process ID: "))
					end,
					cwd = "${workspaceFolder}",
					sourceMaps = true,
					protocol = "inspector",
				},
			}

			-- TypeScript 使用相同的配置
			dap.configurations.typescript = dap.configurations.javascript

			-- ========== Go 配置 ==========
			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
				},
			}

			dap.configurations.go = {
				{
					name = "Debug Go Program",
					type = "delve",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Debug Go Package",
					type = "delve",
					request = "launch",
					program = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Debug Go Tests",
					type = "delve",
					request = "launch",
					mode = "test",
					program = "${workspaceFolder}",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Attach to Go Process",
					type = "delve",
					request = "attach",
					mode = "local",
					processId = function()
						return tonumber(vim.fn.input("Process ID: "))
					end,
					cwd = "${workspaceFolder}",
				},
			}

			-- ========== PHP 配置 ==========
			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = { vim.fn.expand("~/.local/share/nvim/mason/packages/php-debug-adapter/extension/out/phpDebug.js") },
			}

			dap.configurations.php = {
				{
					name = "Listen for Xdebug",
					type = "php",
					request = "launch",
					port = 9003,
					pathMappings = {
						["/var/www/html"] = "${workspaceFolder}",
					},
				},
				{
					name = "Launch PHP Script",
					type = "php",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					port = 0,
					runtimeArgs = {
						"-dxdebug.start_with_request=yes",
					},
					env = {
						XDEBUG_MODE = "debug,develop",
						XDEBUG_CONFIG = "client_port=${port}",
					},
				},
			}

			-- ========== Bash 配置 ==========
			dap.adapters.bashdb = {
				type = "executable",
				command = vim.fn.expand("~/.local/share/nvim/mason/packages/bash-debug-adapter/bash-debug-adapter"),
				name = "bashdb",
			}

			dap.configurations.sh = {
				{
					name = "Debug Bash Script",
					type = "bashdb",
					request = "launch",
					showDebugOutput = true,
					pathBashdb = vim.fn.expand("~/.local/share/nvim/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb"),
					pathBashdbLib = vim.fn.expand("~/.local/share/nvim/mason/packages/bash-debug-adapter/extension/bashdb_dir"),
					trace = true,
					file = "${file}",
					program = "${file}",
					cwd = "${workspaceFolder}",
					pathCat = "cat",
					pathBash = "/bin/bash",
					pathMktemp = "mktemp",
					pathPkill = "pkill",
					args = {},
					env = {},
					terminalKind = "integrated",
				},
			}

			-- ========== Java 配置 ==========
			dap.configurations.java = {
				{
					name = "Debug Java Application",
					type = "java",
					request = "launch",
					mainClass = function()
						return vim.fn.input("Main class: ", vim.fn.expand("%:t:r"))
					end,
					projectName = function()
						return vim.fn.input("Project name: ", vim.fn.fnamemodify(vim.fn.getcwd(), ":t"))
					end,
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
				},
				{
					name = "Attach to Java Process",
					type = "java",
					request = "attach",
					hostName = "localhost",
					port = function()
						return tonumber(vim.fn.input("Debug port: ", "5005"))
					end,
				},
			}

			-- ========== .NET Core 配置 ==========
			dap.adapters.netcoredbg = {
				type = "executable",
				command = "netcoredbg",
				args = { "--interpreter=vscode" },
			}

			dap.configurations.cs = {
				{
					name = "Launch .NET Core",
					type = "netcoredbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					args = {},
				},
				{
					name = "Launch .NET Core with Args",
					type = "netcoredbg",
					request = "launch",
					program = function()
						return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopAtEntry = false,
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
				},
				{
					name = "Attach to .NET Process",
					type = "netcoredbg",
					request = "attach",
					processId = function()
						return tonumber(vim.fn.input("Process ID: "))
					end,
				},
			}

			-- ========== Docker 调试配置 ==========
			local docker_configs = {
				python = {
					{
						name = "Docker: Python Remote Debug",
						type = "python",
						request = "attach",
						connect = {
							host = "localhost",
							port = 5678,
						},
						localRoot = "${workspaceFolder}",
						remoteRoot = "/app",
						justMyCode = false,
					},
				},
				node = {
					{
						name = "Docker: Node.js Remote Debug",
						type = "node2",
						request = "attach",
						address = "localhost",
						port = 9229,
						localRoot = "${workspaceFolder}",
						remoteRoot = "/app",
						sourceMaps = true,
					},
				},
				go = {
					{
						name = "Docker: Go Remote Debug",
						type = "delve",
						request = "attach",
						mode = "remote",
						remotePath = "/go/src/app",
						port = 2345,
						host = "localhost",
					},
				},
			}

			-- 合并Docker配置到现有配置
			for lang, configs in pairs(docker_configs) do
				if lang == "python" then
					for _, config in ipairs(configs) do
						table.insert(dap.configurations.python, config)
					end
				elseif lang == "node" then
					for _, config in ipairs(configs) do
						table.insert(dap.configurations.javascript, config)
						table.insert(dap.configurations.typescript, config)
					end
				elseif lang == "go" then
					for _, config in ipairs(configs) do
						table.insert(dap.configurations.go, config)
					end
				end
			end

			-- ========== Dart/Flutter 配置 ==========
			dap.adapters.dart = {
				type = "executable",
				command = "dart",
				args = { "debug_adapter" },
			}

			dap.configurations.dart = {
				{
					name = "Launch Dart",
					type = "dart",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					args = {},
				},
				{
					name = "Flutter: Debug",
					type = "dart",
					request = "launch",
					program = "${workspaceFolder}/lib/main.dart",
					cwd = "${workspaceFolder}",
					toolArgs = { "--debug" },
					flutterMode = "debug",
				},
				{
					name = "Flutter: Profile",
					type = "dart",
					request = "launch",
					program = "${workspaceFolder}/lib/main.dart",
					cwd = "${workspaceFolder}",
					toolArgs = { "--profile" },
					flutterMode = "profile",
				},
			}

			-- ========== Ruby 配置 ==========
			dap.adapters.ruby = {
				type = "executable",
				command = "readapt",
				args = { "stdio" },
			}

			dap.configurations.ruby = {
				{
					name = "Debug Ruby",
					type = "ruby",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Debug Ruby with Args",
					type = "ruby",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
					args = function()
						local args_str = vim.fn.input("Arguments: ")
						return vim.split(args_str, " ", { trimempty = true })
					end,
				},
				{
					name = "Debug Rails Server",
					type = "ruby",
					request = "launch",
					program = "${workspaceFolder}/bin/rails",
					args = { "server" },
					cwd = "${workspaceFolder}",
				},
			}

			-- ========== Kotlin 配置 ==========
			dap.configurations.kotlin = {
				{
					name = "Launch Kotlin",
					type = "kotlin",
					request = "launch",
					projectRoot = "${workspaceFolder}",
					mainClass = function()
						return vim.fn.input("Main class: ")
					end,
				},
			}

			-- ========== Swift 配置 ==========
			dap.adapters.lldb = {
				type = "executable",
				command = "/usr/bin/lldb-vscode",
				name = "lldb",
			}

			dap.configurations.swift = {
				{
					name = "Debug Swift",
					type = "lldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
					args = {},
				},
			}

			-- ========== Perl 配置 ==========
			dap.adapters.perl = {
				type = "executable",
				command = "perl",
				args = { "-d", "${file}" },
			}

			dap.configurations.perl = {
				{
					name = "Debug Perl",
					type = "perl",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
			}

			-- ========== PowerShell 配置 ==========
			dap.adapters.pwsh = {
				type = "executable",
				command = "pwsh",
				args = { "-Command", "PowerShellEditorServices.VSCode.Module\\Start-EditorServices" },
			}

			dap.configurations.ps1 = {
				{
					name = "Debug PowerShell Script",
					type = "pwsh",
					request = "launch",
					script = "${file}",
					cwd = "${workspaceFolder}",
				},
			}

			-- ========== Lua 配置 ==========
			dap.adapters.lua = {
				type = "executable",
				command = vim.fn.expand("~/.local/share/nvim/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.lua"),
				args = { vim.fn.expand("~/.local/share/nvim/mason/packages/local-lua-debugger-vscode/extension/debugAdapter.lua") },
			}

			dap.configurations.lua = {
				{
					name = "Debug Lua Script",
					type = "lua",
					request = "launch",
					program = "${file}",
					cwd = "${workspaceFolder}",
				},
				{
					name = "Debug Neovim Lua",
					type = "lua",
					request = "launch",
					program = function()
						return vim.fn.input("Path to Neovim: ", "/usr/bin/nvim")
					end,
					args = { "--headless", "-u", "NONE", "-c", "luafile ${file}" },
					cwd = "${workspaceFolder}",
				},
			}

			-- ========== 测试框架调试配置 ==========
			local test_configs = {
				jest = {
					name = "Debug Jest Tests",
					type = "node2",
					request = "launch",
					program = "${workspaceFolder}/node_modules/.bin/jest",
					args = { "--runInBand", "--no-cache", "--no-coverage", "${file}" },
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
					internalConsoleOptions = "neverOpen",
				},
				mocha = {
					name = "Debug Mocha Tests",
					type = "node2",
					request = "launch",
					program = "${workspaceFolder}/node_modules/.bin/mocha",
					args = { "${file}" },
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
				},
				pytest = {
					name = "Debug PyTest",
					type = "python",
					request = "launch",
					module = "pytest",
					args = { "${file}" },
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
				},
				unittest = {
					name = "Debug Python UnitTest",
					type = "python",
					request = "launch",
					module = "unittest",
					args = { "${file}" },
					cwd = "${workspaceFolder}",
					console = "integratedTerminal",
				},
			}

			-- 添加测试配置到对应语言
			table.insert(dap.configurations.javascript, test_configs.jest)
			table.insert(dap.configurations.javascript, test_configs.mocha)
			table.insert(dap.configurations.typescript, test_configs.jest)
			table.insert(dap.configurations.typescript, test_configs.mocha)
			table.insert(dap.configurations.python, test_configs.pytest)
			table.insert(dap.configurations.python, test_configs.unittest)

			-- ========== 远程调试配置助手 ==========
			local function setup_remote_debug()
				local remote_configs = {
					{
						name = "🌐 SSH Remote Python Debug",
						type = "python",
						request = "attach",
						connect = {
							host = function()
								return vim.fn.input("SSH Host: ")
							end,
							port = function()
								return tonumber(vim.fn.input("Debug Port: ", "5678"))
							end,
						},
						localRoot = "${workspaceFolder}",
						remoteRoot = function()
							return vim.fn.input("Remote Path: ", "/home/user/project")
						end,
					},
					{
						name = "🌐 SSH Remote Node.js Debug",
						type = "node2",
						request = "attach",
						address = function()
							return vim.fn.input("SSH Host: ")
						end,
						port = function()
							return tonumber(vim.fn.input("Debug Port: ", "9229"))
						end,
						localRoot = "${workspaceFolder}",
						remoteRoot = function()
							return vim.fn.input("Remote Path: ", "/home/user/project")
						end,
					},
				}
				
				return remote_configs
			end

			-- ========== 多进程调试配置 ==========
			local function setup_multi_process_debug()
				return {
					{
						name = "🔄 Multi-Process Python",
						type = "python",
						request = "launch",
						program = "${file}",
						console = "integratedTerminal",
						cwd = "${workspaceFolder}",
						subProcess = true,
						-- Enable debugging of child processes
						env = {
							PYTHONPATH = "${workspaceFolder}",
						},
					},
					{
						name = "🔄 Multi-Process Node.js",
						type = "node2",
						request = "launch",
						program = "${file}",
						cwd = "${workspaceFolder}",
						autoAttachChildProcesses = true,
						console = "integratedTerminal",
					},
				}
			end

			-- 添加多进程调试配置
			local multi_process_configs = setup_multi_process_debug()
			table.insert(dap.configurations.python, multi_process_configs[1])
			table.insert(dap.configurations.javascript, multi_process_configs[2])
			table.insert(dap.configurations.typescript, multi_process_configs[2])

			-- ========== 通用调试配置函数 ==========
			-- 自动检测项目类型并提供相应的调试配置
			local function get_debug_configs()
				local configs = {}
				local cwd = vim.fn.getcwd()
				
				-- 检测 Rust 项目
				if vim.fn.filereadable(cwd .. "/Cargo.toml") == 1 then
					table.insert(configs, { name = "🦀 Debug Rust Project", filetype = "rust" })
				end
				
				-- 检测 Node.js 项目
				if vim.fn.filereadable(cwd .. "/package.json") == 1 then
					table.insert(configs, { name = "📦 Debug Node.js Project", filetype = "javascript" })
					-- 检测是否有测试框架
					local package_json = vim.fn.readfile(cwd .. "/package.json")
					local content = table.concat(package_json, "\n")
					if string.find(content, "jest") then
						table.insert(configs, { name = "🧪 Debug Jest Tests", filetype = "javascript", config = "Debug Jest Tests" })
					end
					if string.find(content, "mocha") then
						table.insert(configs, { name = "🧪 Debug Mocha Tests", filetype = "javascript", config = "Debug Mocha Tests" })
					end
				end
				
				-- 检测 Python 项目
				if vim.fn.filereadable(cwd .. "/requirements.txt") == 1 or
				   vim.fn.filereadable(cwd .. "/setup.py") == 1 or
				   vim.fn.filereadable(cwd .. "/pyproject.toml") == 1 then
					table.insert(configs, { name = "🐍 Debug Python Project", filetype = "python" })
					-- 检测 Django
					if vim.fn.filereadable(cwd .. "/manage.py") == 1 then
						table.insert(configs, { name = "🌐 Debug Django Project", filetype = "python", config = "Launch Django" })
					end
					-- 检测 Flask
					if vim.fn.filereadable(cwd .. "/app.py") == 1 or vim.fn.filereadable(cwd .. "/application.py") == 1 then
						table.insert(configs, { name = "🌶️ Debug Flask Project", filetype = "python", config = "Launch Flask" })
					end
					-- 检测测试
					if vim.fn.filereadable(cwd .. "/pytest.ini") == 1 or vim.fn.glob(cwd .. "/**/test_*.py") ~= "" then
						table.insert(configs, { name = "🧪 Debug PyTest", filetype = "python", config = "Debug PyTest" })
					end
				end
				
				-- 检测 Go 项目
				if vim.fn.filereadable(cwd .. "/go.mod") == 1 then
					table.insert(configs, { name = "🐹 Debug Go Project", filetype = "go" })
					table.insert(configs, { name = "🧪 Debug Go Tests", filetype = "go", config = "Debug Go Tests" })
				end
				
				-- 检测 C/C++ 项目
				if vim.fn.filereadable(cwd .. "/Makefile") == 1 or
				   vim.fn.filereadable(cwd .. "/CMakeLists.txt") == 1 then
					table.insert(configs, { name = "⚡ Debug C/C++ Project", filetype = "c" })
				end
				
				-- 检测 .NET 项目
				if vim.fn.glob(cwd .. "/**/*.csproj") ~= "" or
				   vim.fn.glob(cwd .. "/**/*.sln") ~= "" then
					table.insert(configs, { name = "💙 Debug .NET Project", filetype = "cs" })
				end
				
				-- 检测 Java 项目
				if vim.fn.filereadable(cwd .. "/pom.xml") == 1 or
				   vim.fn.filereadable(cwd .. "/build.gradle") == 1 or
				   vim.fn.glob(cwd .. "/**/*.java") ~= "" then
					table.insert(configs, { name = "☕ Debug Java Project", filetype = "java" })
				end
				
				-- 检测 Ruby 项目
				if vim.fn.filereadable(cwd .. "/Gemfile") == 1 then
					table.insert(configs, { name = "💎 Debug Ruby Project", filetype = "ruby" })
					if vim.fn.filereadable(cwd .. "/config/application.rb") == 1 then
						table.insert(configs, { name = "🚂 Debug Rails Project", filetype = "ruby", config = "Debug Rails Server" })
					end
				end
				
				-- 检测 PHP 项目
				if vim.fn.filereadable(cwd .. "/composer.json") == 1 or
				   vim.fn.glob(cwd .. "/**/*.php") ~= "" then
					table.insert(configs, { name = "🐘 Debug PHP Project", filetype = "php" })
				end
				
				-- 检测 Dart/Flutter 项目
				if vim.fn.filereadable(cwd .. "/pubspec.yaml") == 1 then
					table.insert(configs, { name = "🎯 Debug Dart Project", filetype = "dart" })
					if vim.fn.isdirectory(cwd .. "/android") == 1 and vim.fn.isdirectory(cwd .. "/ios") == 1 then
						table.insert(configs, { name = "📱 Debug Flutter App", filetype = "dart", config = "Flutter: Debug" })
					end
				end
				
				-- 检测 Docker 项目
				if vim.fn.filereadable(cwd .. "/Dockerfile") == 1 or
				   vim.fn.filereadable(cwd .. "/docker-compose.yml") == 1 then
					table.insert(configs, { name = "🐳 Docker Remote Debug", filetype = "docker" })
				end
				
				return configs
			end

			-- 智能配置选择函数
			local function select_and_run_config(filetype, config_name)
				if not dap.configurations[filetype] then
					vim.notify("No debug configurations found for " .. filetype, vim.log.levels.ERROR)
					return
				end
				
				if config_name then
					-- 查找特定配置
					for _, config in ipairs(dap.configurations[filetype]) do
						if config.name == config_name then
							dap.run(config)
							return
						end
					end
					vim.notify("Configuration '" .. config_name .. "' not found", vim.log.levels.ERROR)
				else
					-- 如果只有一个配置，直接运行
					if #dap.configurations[filetype] == 1 then
						dap.run(dap.configurations[filetype][1])
					else
						-- 让用户选择具体配置
						vim.ui.select(dap.configurations[filetype], {
							prompt = "Select debug configuration:",
							format_item = function(item)
								return item.name
							end,
						}, function(choice)
							if choice then
								dap.run(choice)
							end
						end)
					end
				end
			end

			-- 快速调试当前文件
			local function quick_debug_current_file()
				local ft = vim.bo.filetype
				local current_file = vim.fn.expand("%:p")
				
				-- 根据文件类型和文件名智能选择配置
				if ft == "python" then
					if string.find(current_file, "test_") or string.find(current_file, "_test") then
						select_and_run_config("python", "Debug PyTest")
					else
						select_and_run_config("python", "Launch Current File")
					end
				elseif ft == "javascript" or ft == "typescript" then
					if string.find(current_file, "test") or string.find(current_file, "spec") then
						select_and_run_config(ft, "Debug Jest Tests")
					else
						select_and_run_config(ft, "Launch Node.js")
					end
				elseif ft == "go" then
					if string.find(current_file, "_test.go") then
						select_and_run_config("go", "Debug Go Tests")
					else
						select_and_run_config("go", "Debug Go Program")
					end
				else
					-- 默认行为：继续执行
					dap.continue()
				end
			end

			-- 创建调试配置管理命令
			vim.api.nvim_create_user_command("DapSelectConfig", function()
				local configs = get_debug_configs()
				if #configs == 0 then
					vim.notify("No debug configurations found for current project", vim.log.levels.WARN)
					return
				end
				
				vim.ui.select(configs, {
					prompt = "Select debug configuration:",
					format_item = function(item)
						return item.name
					end,
				}, function(choice)
					if choice then
						if choice.filetype == "docker" then
							-- Docker 特殊处理
							local docker_types = { "python", "javascript", "go" }
							vim.ui.select(docker_types, {
								prompt = "Select Docker debug type:",
							}, function(docker_type)
								if docker_type then
									select_and_run_config(docker_type, "Docker: " .. docker_type:gsub("^%l", string.upper) .. " Remote Debug")
								end
							end)
						else
							select_and_run_config(choice.filetype, choice.config)
						end
					end
				end)
			end, { desc = "Select and run debug configuration" })

			-- 快速调试命令
			vim.api.nvim_create_user_command("DapQuickDebug", function()
				quick_debug_current_file()
			end, { desc = "Quick debug current file with smart detection" })

			-- 调试历史记录
			local debug_history = {}
			local function add_to_history(config)
				table.insert(debug_history, 1, {
					name = config.name,
					type = config.type,
					filetype = vim.bo.filetype,
					time = os.date("%H:%M:%S"),
				})
				if #debug_history > 10 then
					table.remove(debug_history)
				end
			end

			-- 重复上次调试命令
			vim.api.nvim_create_user_command("DapRepeatLast", function()
				if #debug_history == 0 then
					vim.notify("No debug history found", vim.log.levels.WARN)
					return
				end
				
				local last = debug_history[1]
				select_and_run_config(last.filetype, last.name)
			end, { desc = "Repeat last debug configuration" })

			-- 显示调试历史
			vim.api.nvim_create_user_command("DapHistory", function()
				if #debug_history == 0 then
					vim.notify("No debug history found", vim.log.levels.INFO)
					return
				end
				
				vim.ui.select(debug_history, {
					prompt = "Debug History:",
					format_item = function(item)
						return string.format("[%s] %s (%s)", item.time, item.name, item.filetype)
					end,
				}, function(choice)
					if choice then
						select_and_run_config(choice.filetype, choice.name)
					end
				end)
			end, { desc = "Show debug history and select configuration" })

			-- 环境变量配置助手
			local function setup_env_vars()
				local env_configs = {
					development = {
						DEBUG = "1",
						NODE_ENV = "development",
						FLASK_ENV = "development",
						DJANGO_DEBUG = "True",
					},
					production = {
						DEBUG = "0",
						NODE_ENV = "production",
						FLASK_ENV = "production",
						DJANGO_DEBUG = "False",
					},
					testing = {
						DEBUG = "1",
						NODE_ENV = "test",
						FLASK_ENV = "testing",
						DJANGO_DEBUG = "True",
						PYTEST_CURRENT_TEST = "1",
					},
				}
				
				return env_configs
			end

			-- 添加环境配置到Python和Node.js配置
			local env_configs = setup_env_vars()
			for _, config in ipairs(dap.configurations.python) do
				if not config.env then
					config.env = {}
				end
				for key, value in pairs(env_configs.development) do
					if not config.env[key] then
						config.env[key] = value
					end
				end
			end

			-- 监听调试事件以记录历史
			dap.listeners.before.launch.history = function(session, body)
				add_to_history(body)
			end
		end,
		keys = {
			{
				"<leader>dp",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},

			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},

			{
				"<leader>dtc",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},

			{
				"<leader>dT",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<space><space>",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.open()
				end,
				desc = "Open REPL",
			},
			{
				"<leader>de",
				function()
					require("dap").repl.run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>ds",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>dx",
				function()
					require("dap").repl.close()
				end,
				desc = "Close REPL",
			},
			{
				"<F6>",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			-- 高级调试快捷键
			{
				"<leader>dP",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Conditional Breakpoint",
			},
			{
				"<leader>dL",
				function()
					require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
				end,
				desc = "Log Point",
			},
			{
				"<leader>dC",
				function()
					require("dap").clear_breakpoints()
				end,
				desc = "Clear All Breakpoints",
			},
			{
				"<leader>dl",
				function()
					require("dap").list_breakpoints()
				end,
				desc = "List Breakpoints",
			},
			{
				"<leader>dR",
				function()
					require("dap").restart()
				end,
				desc = "Restart Debug Session",
			},
			{
				"<leader>dS",
				function()
					vim.cmd("DapSelectConfig")
				end,
				desc = "Select Debug Configuration",
			},
			{
				"<leader>dh",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Debug Hover",
			},
			{
				"<leader>df",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.frames)
				end,
				desc = "Debug Frames",
			},
			{
				"<leader>dv",
				function()
					local widgets = require("dap.ui.widgets")
					widgets.centered_float(widgets.scopes)
				end,
				desc = "Debug Variables",
			},
			-- 新增的高级调试功能
			{
				"<leader>dq",
				function()
					vim.cmd("DapQuickDebug")
				end,
				desc = "Quick Debug Current File",
			},
			{
				"<leader>da",
				function()
					-- 自动设置断点在当前行并开始调试
					require("dap").toggle_breakpoint()
					require("dap").continue()
				end,
				desc = "Auto Debug from Current Line",
			},
			{
				"<leader>dH",
				function()
					vim.cmd("DapHistory")
				end,
				desc = "Debug History",
			},
			{
				"<leader>dM",
				function()
					vim.cmd("DapRepeatLast")
				end,
				desc = "Repeat Last Debug",
			},
			{
				"<leader>dB",
				function()
					-- 在函数开始处设置断点
					local line = vim.api.nvim_get_current_line()
					local row = vim.api.nvim_win_get_cursor(0)[1]
					-- 搜索函数定义
					local patterns = { "def ", "function ", "func ", "fn ", "pub fn ", "async fn " }
					for i = row, 1, -1 do
						local current_line = vim.api.nvim_buf_get_lines(0, i-1, i, false)[1] or ""
						for _, pattern in ipairs(patterns) do
							if string.find(current_line, pattern) then
								vim.api.nvim_win_set_cursor(0, {i, 0})
								require("dap").toggle_breakpoint()
								return
							end
						end
					end
					vim.notify("No function definition found", vim.log.levels.WARN)
				end,
				desc = "Breakpoint at Function Start",
			},
			{
				"<leader>dE",
				function()
					-- 在异常处设置断点
					require("dap").set_exception_breakpoints({"all"})
					vim.notify("Exception breakpoints enabled", vim.log.levels.INFO)
				end,
				desc = "Enable Exception Breakpoints",
			},
			{
				"<leader>dw",
				function()
					-- 观察表达式
					local expr = vim.fn.input("Watch expression: ")
					if expr ~= "" then
						require("dap.ui.widgets").hover(expr)
					end
				end,
				desc = "Watch Expression",
			},
			{
				"<leader>dt",
				function()
					-- 切换调试模式（step/continue）
					local session = require("dap").session()
					if session then
						local mode = vim.g.dap_step_mode or "continue"
						if mode == "continue" then
							vim.g.dap_step_mode = "step"
							require("dap").step_over()
							vim.notify("Switched to step mode", vim.log.levels.INFO)
						else
							vim.g.dap_step_mode = "continue"
							require("dap").continue()
							vim.notify("Switched to continue mode", vim.log.levels.INFO)
						end
					else
						require("dap").continue()
					end
				end,
				desc = "Toggle Debug Mode",
			},
			{
				"<leader>dD",
				function()
					-- 禁用所有断点
					local breakpoints = require("dap.breakpoints").get()
					if next(breakpoints) then
						require("dap.breakpoints").clear()
						vim.g.dap_breakpoints_backup = breakpoints
						vim.notify("All breakpoints disabled", vim.log.levels.INFO)
					else
						-- 恢复断点
						local backup = vim.g.dap_breakpoints_backup
						if backup then
							for bufnr, buf_bps in pairs(backup) do
								require("dap.breakpoints").set(bufnr, buf_bps)
							end
							vim.g.dap_breakpoints_backup = nil
							vim.notify("Breakpoints restored", vim.log.levels.INFO)
						end
					end
				end,
				desc = "Toggle All Breakpoints",
			},
			{
				"<leader>dF",
				function()
					-- 查找并设置断点在包含特定文本的行
					local search_text = vim.fn.input("Find and break at line containing: ")
					if search_text ~= "" then
						local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
						for i, line in ipairs(lines) do
							if string.find(line, search_text) then
								vim.api.nvim_win_set_cursor(0, {i, 0})
								require("dap").toggle_breakpoint()
								vim.notify(string.format("Breakpoint set at line %d", i), vim.log.levels.INFO)
								return
							end
						end
						vim.notify("Text not found", vim.log.levels.WARN)
					end
				end,
				desc = "Find and Breakpoint",
			},
			{
				"<leader>dN",
				function()
					-- 跳转到下一个断点
					local breakpoints = require("dap.breakpoints").get()
					local current_buf = vim.api.nvim_get_current_buf()
					local current_line = vim.api.nvim_win_get_cursor(0)[1]
					
					if breakpoints[current_buf] then
						local next_bp = nil
						for _, bp in ipairs(breakpoints[current_buf]) do
							if bp.line > current_line then
								next_bp = bp
								break
							end
						end
						if next_bp then
							vim.api.nvim_win_set_cursor(0, {next_bp.line, 0})
							vim.notify(string.format("Jumped to breakpoint at line %d", next_bp.line), vim.log.levels.INFO)
						else
							vim.notify("No breakpoints found after current line", vim.log.levels.WARN)
						end
					else
						vim.notify("No breakpoints in current buffer", vim.log.levels.WARN)
					end
				end,
				desc = "Jump to Next Breakpoint",
			},
		},
	},
	{
		"jay-babu/mason-nvim-dap.nvim",
		---@type MasonNvimDapSettings
		opts = {
			-- This line is essential to making automatic installation work
			-- :exploding-brain
			handlers = {},
			automatic_installation = {
				-- These will be configured by separate plugins.
				exclude = {
					"delve",
					"python",
				},
			},
			-- DAP servers: Mason will be invoked to install these if necessary.
			ensure_installed = {
				"bash",
				"codelldb",
				"php",
				"python",
			},
		},
		dependencies = {
			"mfussenegger/nvim-dap",
			"williamboman/mason.nvim",
		},
	},
	{
		{
			"mfussenegger/nvim-dap-python",
			lazy = true,
			config = function()
				local python = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
				require("dap-python").setup(python)
			end,
			-- Consider the mappings at
			-- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#mappings
			dependencies = {
				"mfussenegger/nvim-dap",
			},
		},
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		config = true,
		dependencies = {
			"mfussenegger/nvim-dap",
		},
	},
	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"jay-babu/mason-nvim-dap.nvim",
			"leoluz/nvim-dap-go",
			"mfussenegger/nvim-dap-python",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		opts = {
			icons = {
				expanded = icons.ui.ArrowOpen,
				collapsed = icons.ui.ArrowClosed,
				current_frame = icons.ui.Indicator,
			},
			mappings = {
				edit = "e",
				expand = { "<CR>", "<2-LeftMouse>" },
				open = "o",
				remove = "d",
				repl = "r",
				toggle = "t",
			},
			controls = {
				enabled = true,
				element = "repl",
				icons = {
					pause = icons.dap.Pause,
					play = icons.dap.Play,
					step_into = icons.dap.StepInto,
					step_over = icons.dap.StepOver,
					step_out = icons.dap.StepOut,
					step_back = icons.dap.StepBack,
					run_last = icons.dap.RunLast,
					terminate = icons.dap.Terminate,
				},
			},
			layouts = {
				{
					elements = {
						-- Provide as ID strings or tables with "id" and "size" keys
						{
							id = "scopes",
							size = 0.3, -- Can be float or integer > 1
						},
						{ id = "watches", size = 0.3 },
						{ id = "stacks", size = 0.3 },
						{ id = "breakpoints", size = 0.1 },
					},
					size = 0.2,
					position = "left",
				},
				{
					elements = {
						{ id = "console", size = 0.55 },
						{ id = "repl", size = 0.45 },
					},
					position = "bottom",
					size = 0.25,
				},
			},
			floating = {
				max_height = nil,
				max_width = nil,
				border = "single",
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
			render = { indent = 1, max_value_lines = 85 },
		},
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
			{
				"\\s",
				function()
					require("dapui").eval()
				end,
			},
		},
		config = function(_, opts)
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
		end,
	},
}
