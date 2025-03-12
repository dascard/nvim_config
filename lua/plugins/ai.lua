return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		cmd = "CopilotChat",
		dependencies = {
			{ "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
			{ "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
		},
		build = "make tiktoken",
		opts = function()
			local user = vim.env.USER or "User"
			user = user:sub(1, 1):upper() .. user:sub(2)
			return {
				auto_insert_mode = true,
				question_header = "  " .. user .. " ",
				answer_header = "  Copilot ",
				model = "claude-3.7-sonnet",
				prompts = {
					Explain = {
						prompt = "使用中文解释当前选中的这段代码,并写出注释",
						system_prompt = "COPILOT_EXPLAIN",
					},
					Review = {
						prompt = "检查这段代码,并使用中文回答",
						system_prompt = "COPILOT_REVIEW",
					},
					Fix = {
						prompt = "使用中文描述这段代码的问题,并提出解决方案",
					},
					Optimize = {
						prompt = "使用中文描述这段代码可能存在的问题,并提出优化方案",
					},
					Docs = {
						prompt = "使用中文描述这段代码的功能,并提供文档和注释",
					},
					Test = {
						prompt = "请为这段代码提供测试用例,并用中文回答",
					},
					Commit = {
						prompt = "请使用中文为当前的更改生成提交消息",
						context = "git:staged",
					},
				},
				window = {
					width = 0.4,
				},
			}
		end,
		keys = {
			{ "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>cco",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)/ CopilotChatOpen",
				mode = { "n", "v" },
			},
			{
				"<leader>ccc",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)/ CopilotChatClear",
				mode = { "n", "v" },
			},
			{
				"<leader>ccq",
				function()
					vim.ui.input({
						prompt = "Quick Chat: ",
					}, function(input)
						if input ~= "" then
							require("CopilotChat").ask(input)
						end
					end)
				end,
				desc = "Quick Chat (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ccp",
				function()
					require("CopilotChat").select_prompt()
				end,
				desc = "CopilotChatPreset",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})

			chat.setup(opts)
		end,
	},
	{
		"folke/edgy.nvim",
		optional = true,
		opts = function(_, opts)
			opts.right = opts.right or {}
			table.insert(opts.right, {
				ft = "copilot-chat",
				title = "Copilot Chat",
				size = { width = 50 },
			})
		end,
	},
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "BufReadPost",
		opts = {
			panel = {
				enabled = false,
				auto_refresh = false,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
					accept = "<CR>",
					refresh = "gr",
					open = "<M-CR>",
				},
				layout = {
					position = "bottom", -- | top | left | right
					ratio = 0.4,
				},
			},

			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-j>",
					accept_word = "<C-l>",
					accept_line = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				help = false,
				gitcommit = false,
				gitrebase = false,
				hgcommit = false,
				markdown = true,
				svn = false,
				cvs = false,
				["."] = false,
			},
			copilot_node_command = "node", -- Node.js version must be > 16.x
			server_opts_overrides = {},
		},
	},
}
