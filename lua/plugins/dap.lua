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
local dap = require("dap")

dap.configurations.rust = {
	{
		name = "npulearn",
		type = "codelldb",
		request = "launch",
		program = function()
			return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
		end,
		cwd = "${workspaceFolder}",
		stopOnEntry = false,
	},
}

return {
	{
		"mfussenegger/nvim-dap",
		lazy = true,
		optional = true,
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
