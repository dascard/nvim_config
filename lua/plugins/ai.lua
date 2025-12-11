-- lua/plugins/ai.lua

return {
	-- 1. Copilot.lua: 核心 GitHub Copilot Agent 提供者
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",       -- 按需加载
		event = "InsertEnter", -- 在插入模式时初始化 Copilot
		branch = "master",     -- 该插件的默认分支是 main
		commit = "acf547e",
		build = ":Copilot auth", -- 安装后执行认证
		opts = {
			suggestion = {
				enabled = true,
				auto_trigger = true,
				debounce = 75,
				keymap = {
					accept = "<C-j>", -- Ctrl+J 接受 Copilot 建议
					accept_word = "<C-l>", -- Ctrl+L 接受单词
					accept_line = "<C-y>", -- Ctrl+Y 接受行（避免与 avante 的 <M-l> 冲突）
					next = "<C-]>",   -- Ctrl+] 下一个建议（避免与 avante 的 <M-]> 冲突）
					prev = "<C-[>",   -- Ctrl+[ 上一个建议（避免与 avante 的 <M-[> 冲突）
					dismiss = "<C-e>", -- Ctrl+E 关闭建议
				},
			},
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					jump_prev = "gk", -- 改为 gk 避免与 avante jump 冲突
					jump_next = "gj", -- 改为 gj 避免与 avante jump 冲突
					accept = "<CR>",
					refresh = "gr",
					open = "<M-o>", -- Meta/Alt + o
				},
				layout = {
					position = "bottom",
					ratio = 0.4,
				},
			},
			filetypes = {
				["*"] = true,
				yaml = true,
				markdown = true,
				terraform = true,
				help = false,
				gitcommit = true,
				gitrebase = false,
				hgcommit = false,
				svn = false,
				cvs = false,
				["."] = false,
				["copilot-chat"] = false,
				["copilotpanel"] = false,
			},
			-- 指定 Node.js 路径，尤其在 Windows 上
			copilot_node_command = vim.fn.has("win32") == 1 and "node.exe" or "node",
			server_opts_overrides = {
				-- trace = "verbose", -- 如需详细日志可取消注释
				checkPrerelease = true, -- 查看是否有预发布版本
			},
			-- 自定义错误处理
			on_error = function(err_type, message)
				if message and string.find(message, "Agent service not initialized", 1, true) then
					vim.notify(
						"[Copilot] Agent service not initialized (正在启动中，稍后会自动解决).",
						vim.log.levels.INFO
					)
					return -- 抑制这个特定的、通常是良性的错误
				end
				-- 允许默认处理其他错误
				return true
			end,
		},
		config = function(_, opts)
			-- 确保在尝试 setup 之前 copilot 模块是可用的
			if not pcall(require, "copilot") then
				vim.notify("[Copilot.lua] Failed to load copilot module.", vim.log.levels.ERROR)
				return
			end

			-- 设置 Copilot
			require("copilot").setup(opts)

			-- 首先执行认证状态检查
			vim.defer_fn(function()
				pcall(function() -- 使用 pcall 避免在 copilot.client 不可用时出错
					if require("copilot.client") and not require("copilot.client").is_signed_in() then
						vim.notify(
							"[Copilot.lua] 需要认证！请运行 :Copilot auth 并按照浏览器提示完成。",
							vim.log.levels.WARN,
							{ title = "Copilot Authentication" }
						)
					end
				end)
			end, 2000) -- 延迟2秒执行

			-- 添加自动重新连接逻辑
			vim.defer_fn(function()
				pcall(function()
					if not require("copilot.client").is_running() then
						require("copilot.client").start()
						vim.notify("[Copilot] 尝试重新启动 Copilot 服务...", vim.log.levels.INFO)
					end
				end)
			end, 8000) -- 延迟8秒，给予足够时间进行初次尝试后再重连
		end,
	},
	{
		"folke/sidekick.nvim",
		enabled = false, -- 禁用 sidekick，使用 avante.nvim 替代
		opts = {
			-- add any options here
			cli = {
				mux = {
					backend = "tmux",
					enabled = true,
				},
				win = {
					split = {
						width = 0.4,
					}
				}
			},
		},
		keys = {
			{
				"<M-|>",
				function() require("sidekick.cli").toggle() end,
				desc = "Sidekick Toggle",
				mode = { "n", "t", "i", "x" },
			},
			{
				"<leader>aa",
				function() require("sidekick.cli").toggle() end,
				desc = "Sidekick Toggle CLI",
			},
			{
				"<leader>as",
				function() require("sidekick.cli").select() end,
				-- Or to select only installed tools:
				-- require("sidekick.cli").select({ filter = { installed = true } })
				desc = "Select CLI",
			},
			{
				"<leader>ad",
				function() require("sidekick.cli").close() end,
				desc = "Detach a CLI Session",
			},
			{
				"<leader>at",
				function() require("sidekick.cli").send({ msg = "{this}" }) end,
				mode = { "x", "n" },
				desc = "Send This",
			},
			{
				"<leader>af",
				function() require("sidekick.cli").send({ msg = "{file}" }) end,
				desc = "Send File",
			},
			{
				"<leader>av",
				function() require("sidekick.cli").send({ msg = "{selection}" }) end,
				mode = { "x" },
				desc = "Send Visual Selection",
			},
			{
				"<leader>ap",
				function() require("sidekick.cli").prompt() end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			-- Example of a keybinding to open Claude directly
			{
				"<leader>ac",
				function() require("sidekick.cli").toggle({ name = "claude", focus = true }) end,
				desc = "Sidekick Toggle Claude",
			},
		},
	},

	-- CodeCompanion.nvim: AI Chat 界面
	{
		"olimorris/codecompanion.nvim",
		enabled = false, -- 启用 CodeCompanion
		version = "v17.33.0", -- 固定版本以避免破坏性变更
		event = "VeryLazy",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"zbirenbaum/copilot.lua", -- 用于 copilot adapter
			{
				-- 确保你安装了 render-markdown 以获得更好的渲染效果
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "codecompanion" },
				},
				ft = { "markdown", "codecompanion" },
			},
		},
		opts = {
			strategies = {
				chat = {
					adapter = "gemini_cli", -- 使用 gemini-cli ACP adapter
				},
				inline = {
					adapter = "copilot",
				},
				cmd = {
					adapter = "copilot",
				},
			},
			adapters = {
				-- HTTP adapters
				http = {
					copilot = function()
						return require("codecompanion.adapters").extend("copilot", {
							schema = {
								model = {
									default = "gpt-4o",
								},
							},
						})
					end,
				},
				-- ACP adapters (使用 Agent Client Protocol)
				acp = {
					gemini_cli = function()
						return require("codecompanion.adapters").extend("gemini_cli", {
							commands = {
								default = {
									"gemini",
									"--experimental-acp",
								},
							},
							defaults = {
								auth_method = "oauth-personal", -- 使用 Google 登录凭证
								mcpServers = {},
								timeout = 30000,
							},
							env = {
								NODE_NO_WARNINGS = "1",
								IS_AI_TERMINAL = "1",
							},
						})
					end,
				},
			},
			display = {
				chat = {
					window = {
						layout = "vertical", -- float|vertical|horizontal|buffer
						width = 0.3,
						height = 0.8,
						relative = "editor",
						border = "rounded",
					},
					intro_message = "欢迎使用 CodeCompanion！输入你的问题开始对话。",
					show_settings = false,
					show_token_count = true,
				},
				diff = {
					enabled = true,
					close_chat_at = 240,
					layout = "vertical",
					provider = "default",
				},
				inline = {
					layout = "vertical",
				},
			},
			opts = {
				log_level = "ERROR",
				system_prompt = [[你是一位 AI 编程助手，名为 CodeCompanion。
				你是一位专家级程序员，帮助用户编写、调试和优化代码。
				你应该用中文回复用户的问题。
				当你提供代码修改建议时，请提供清晰的解释。]],
			},
		},
		keys = {
			-- 聊天相关
			{
				"<leader>aa",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "CodeCompanion: Toggle Chat",
				mode = { "n", "v" },
			},
			{
				"<leader>ac",
				"<cmd>CodeCompanionChat<cr>",
				desc = "CodeCompanion: New Chat",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				"<cmd>CodeCompanionActions<cr>",
				desc = "CodeCompanion: Actions Palette",
				mode = { "n", "v" },
			},
			-- Inline 相关
			{
				"<leader>ai",
				"<cmd>CodeCompanion<cr>",
				desc = "CodeCompanion: Inline Assistant",
				mode = { "n", "v" },
			},
			{
				"<leader>ae",
				"<cmd>CodeCompanion /explain<cr>",
				desc = "CodeCompanion: Explain Code",
				mode = "v",
			},
			{
				"<leader>af",
				"<cmd>CodeCompanion /fix<cr>",
				desc = "CodeCompanion: Fix Code",
				mode = "v",
			},
			{
				"<leader>at",
				"<cmd>CodeCompanion /tests<cr>",
				desc = "CodeCompanion: Generate Tests",
				mode = "v",
			},
			-- 快速添加到聊天
			{
				"<leader>av",
				"<cmd>CodeCompanionChat Add<cr>",
				desc = "CodeCompanion: Add Selection to Chat",
				mode = "v",
			},
		},
		config = function(_, opts)
			require("codecompanion").setup(opts)

			-- 设置命令缩写 (可选)
			vim.cmd([[cab cc CodeCompanion]])
			vim.cmd([[cab ccc CodeCompanionChat]])
			vim.cmd([[cab cca CodeCompanionActions]])
		end,
	},

	-- Avante.nvim: AI Chat 界面
	{
		"yetone/avante.nvim",
		enabled = true, -- 已启用
		event = "VeryLazy",
		lazy = false,
		version = false,
		opts = {
			-- 使用 agentic 模式（官方默认，更智能的代码生成和应用）
			mode = "agentic",
			provider = "gemini-cli", -- 使用 Gemini CLI ACP 模式
			auto_suggestions_provider = "copilot",
			providers = {
				copilot = {
					endpoint = "https://api.githubcopilot.com",
					model = "gpt-4o-2024-05-13",
					timeout = 30000,
					extra_request_body = {
						temperature = 0,
						max_tokens = 4096,
					},
				},
			},
			acp_providers = {
				["gemini-cli"] = {
					command = "gemini", -- 使用已安装的 gemini-cli v0.21.0-preview.2
					args = { "--experimental-acp" },
					auth_method = "oauth-personal", -- 使用 Google 登录凭证
					env = {
						HOME = vim.fn.expand("~"),
						XDG_CONFIG_HOME = vim.fn.expand("~/.config"),
						GEMINI_HOME = vim.fn.expand("~/.gemini"),
						NODE_NO_WARNINGS = "1",
						IS_AI_TERMINAL = "1",
					},
				},
			},
			behaviour = {
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = false,
				auto_focus_sidebar = true, -- 自动聚焦侧边栏
			},
			mappings = {
				diff = {
					ours = "co",
					theirs = "ct",
					all_theirs = "ca",
					both = "cb",
					cursor = "cc",
					next = "]x",
					prev = "[x",
				},
				suggestion = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
				},
			},
			hints = { enabled = true },
			windows = {
				position = "right",
				wrap = true,
				width = 30, -- 默认百分比
				height = 30,
				fillchars = "eob: ",
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true,
				},
				-- 官方默认的 spinner 动画
				spinner = {
					editing = {
						"⡀", "⠄", "⠂", "⠁", "⠈", "⠐", "⠠", "⢀",
						"⣀", "⢄", "⢂", "⢁", "⢈", "⢐", "⢠", "⣠",
						"⢤", "⢢", "⢡", "⢨", "⢰", "⣰", "⢴", "⢲",
						"⢱", "⢸", "⣸", "⢼", "⢺", "⢹", "⣹", "⢽",
						"⢻", "⣻", "⢿", "⣿",
					},
					generating = { "·", "✢", "✳", "∗", "✻", "✽" },
					thinking = { "🤔", "💭" },
				},
				input = {
					prefix = "> ",
					height = 8,
				},
				selected_files = {
					height = 6, -- 选中文件窗口的最大高度
				},
				edit = {
					border = { " ", " ", " ", " ", " ", " ", " ", " " }, -- 无边框（官方默认）
					start_insert = true,
				},
				ask = {
					floating = false,
					border = { " ", " ", " ", " ", " ", " ", " ", " " }, -- 无边框（官方默认）
					start_insert = true,
					focus_on_apply = "ours", -- 应用后聚焦到哪个 diff
				},
			},
			highlights = {
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},
			diff = {
				autojump = true,
				list_opener = "copen",
				override_timeoutlen = 500, -- 避免进入 operator-pending 模式
			},
			-- Selector 配置 (用于选择文件等)
			selector = {
				provider = "fzf_lua", -- 使用 fzf-lua 作为选择器
				provider_opts = {},
			},
		},
		build = vim.fn.has("win32") ~= 0
		and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
		or "make",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-mini/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				'MeanderingProgrammer/render-markdown.nvim',
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{
				"<leader>aA",
				function() require("avante.api").ask() end,
				desc = "avante: ask",
				mode = { "n", "v" },
			},
			{
				"<leader>aR",
				function() require("avante.api").refresh() end,
				desc = "avante: refresh",
			},
			{
				"<leader>aE",
				function() require("avante.api").edit() end,
				desc = "avante: edit",
				mode = "v",
			},
		},
		-- 不需要自定义 config，使用默认高亮
	},

	-- 3. copilot-cmp: 为 nvim-cmp 提供 Copilot 补全源
	{
		"zbirenbaum/copilot-cmp",
		enabled = false, -- 禁用，因为 nvim-cmp 已被 blink.cmp 替代
		dependencies = { "nvim-cmp", "zbirenbaum/copilot.lua" },
		opts = {
			fix_keymaps = false,
			-- suggestion_keymap = nil,
			-- formatters = { label = require("copilot_cmp.format").format_label_text }
		},
		config = function(_, opts)
			-- 检查 cmp 模块是否能够加载
			-- if not pcall(require, "cmp") then
			-- 	vim.notify(
				-- 		"[copilot-cmp] nvim-cmp 未加载，copilot-cmp 将不会被配置。",
				-- 		vim.log.levels.WARN,
				-- 		{ title = "Plugin Dependency" }
				-- 	)
				-- 	return
				-- end
				-- 检查 copilot_cmp 模块是否能够加载
				if not pcall(require, "copilot_cmp") then
					vim.notify("[copilot-cmp] Failed to load copilot_cmp module.", vim.log.levels.ERROR)
					return
				end
				-- 设置 copilot-cmp
				require("copilot_cmp").setup(opts)
				-- vim.notify(
					-- 	"[copilot-cmp] 已配置。请确保在 nvim-cmp 的 sources 中添加 'copilot' 并考虑使用 'copilot_cmp.comparators.prioritize'。",
					-- 	vim.log.levels.INFO,
					-- 	{ title = "Copilot CMP" }
					-- )
				end,
			},

			-- 4. edgy.nvim: 窗口管理集成 (可选)


			-- 5. Test Plugin (Irrelevant code for testing)
		}
