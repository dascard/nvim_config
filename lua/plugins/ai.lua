-- lua/plugins/ai.lua

return {
	-- 1. Copilot.lua: 核心 GitHub Copilot Agent 提供者
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot", -- 按需加载
		event = "InsertEnter", -- 在插入模式时初始化 Copilot
		branch = "master", -- 该插件的默认分支是 main
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
					next = "<C-]>", -- Ctrl+] 下一个建议（避免与 avante 的 <M-]> 冲突）
					prev = "<M-p>", -- Alt+p 上一个建议（避免与 <Esc> 冲突，<C-[> 等同于 <Esc>）
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
					},
				},
			},
		},
		keys = {
			{
				"<M-|>",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle",
				mode = { "n", "t", "i", "x" },
			},
			{
				"<leader>aa",
				function()
					require("sidekick.cli").toggle()
				end,
				desc = "Sidekick Toggle CLI",
			},
			{
				"<leader>as",
				function()
					require("sidekick.cli").select()
				end,
				-- Or to select only installed tools:
				-- require("sidekick.cli").select({ filter = { installed = true } })
				desc = "Select CLI",
			},
			{
				"<leader>ad",
				function()
					require("sidekick.cli").close()
				end,
				desc = "Detach a CLI Session",
			},
			{
				"<leader>at",
				function()
					require("sidekick.cli").send({ msg = "{this}" })
				end,
				mode = { "x", "n" },
				desc = "Send This",
			},
			{
				"<leader>af",
				function()
					require("sidekick.cli").send({ msg = "{file}" })
				end,
				desc = "Send File",
			},
			{
				"<leader>av",
				function()
					require("sidekick.cli").send({ msg = "{selection}" })
				end,
				mode = { "x" },
				desc = "Send Visual Selection",
			},
			{
				"<leader>ap",
				function()
					require("sidekick.cli").prompt()
				end,
				mode = { "n", "x" },
				desc = "Sidekick Select Prompt",
			},
			-- Example of a keybinding to open Claude directly
			{
				"<leader>ac",
				function()
					require("sidekick.cli").toggle({ name = "claude", focus = true })
				end,
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
		"guojinc/avante.nvim",
		branch = "fix/acp-improvements",
		enabled = true, -- 已启用
		event = "VeryLazy",
		lazy = false,
		version = false,
		opts = {
			system_prompt = (function()
				local file = io.open(vim.fn.stdpath("config") .. "/avante_system_prompt.md", "r")
				if file then
					local content = file:read("*a")
					file:close()
					return content
				end
				return nil
			end)(),
			-- 模式选择:
			-- "agentic": AI 使用工具直接修改代码（弹窗确认后直接应用）
			-- "legacy": AI 生成 diff，显示冲突标记供你手动选择（co/ct）
			-- 注意: gemini-cli (ACP) 只支持 agentic 模式
			mode = "agentic",
			provider = "codex", -- 使用 Gemini CLI (免费 OAuth)
			-- provider = "gemini", -- 使用 Gemini HTTP API (需要 API key，有配额限制)
			-- provider = "copilot", -- 使用 Copilot HTTP 模式
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
				-- Gemini API (HTTP 模式) - 需要设置环境变量 GEMINI_API_KEY
				-- 获取 API Key: https://aistudio.google.com/app/apikey
				gemini = {
					endpoint = "https://generativelanguage.googleapis.com/v1beta/models",
					model = "gemini-2.5-flash", -- 或 gemini-1.5-pro, gemini-1.5-flash
					api_key_name = "GEMINI_API_KEY",
					timeout = 30000,
					temperature = 0,
					max_tokens = 8192,
				},
			},
			acp_providers = {
				["gemini-cli"] = {
					command = "gemini", -- 使用已安装的 gemini-cli v0.21.0-preview.2
					args = { "--experimental-acp", "-m", "gemini-3-pro-preview" },
					auth_method = "oauth-personal", -- 使用 Google 登录凭证
					env = {
						HOME = vim.fn.expand("~"),
						XDG_CONFIG_HOME = vim.fn.expand("~/.config"),
						GEMINI_HOME = vim.fn.expand("~/.gemini"),
						NODE_NO_WARNINGS = "1",
						IS_AI_TERMINAL = "1",
					},
				},
				["codex"] = {
					command = "npx",
					args = { "@zed-industries/codex-acp" },
					auth_method = "oauth-personal",
					env = {
						NODE_NO_WARNINGS = "1",
					},
				},
			},
			behaviour = {
				auto_suggestions = false,
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = true,
				support_paste_from_clipboard = false,
				auto_focus_sidebar = true, -- 自动聚焦侧边栏
				auto_approve_tool_permissions = false, -- 禁止自动应用更改，需要手动确认
				confirmation_ui_style = "popup", -- 使用弹窗确认 (而不是 inline_buttons)
				enable_fastapply = false, -- 禁用 fastapply，确保使用 str_replace
				-- popup 模式下: y=允许, Y/a/A=全部允许, n/N=拒绝, <CR>=点击选中按钮
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
					insert = "<M-CR>", -- Ctrl+S 发送 (原 <C-CR> 在终端中不可用)
				},
				-- 取消/停止快捷键 (注意: 在 Avante 窗口中使用)
				cancel = {
					normal = { "<C-c>", "q" },
					insert = { "<C-c>" },
				},
				-- 停止模型输出
				stop = "<C-c>",
				sidebar = {
					apply_all = "A",
					apply_cursor = "a",
					retry_user_request = "r", -- 重试上一次请求
					edit_user_request = "e", -- 编辑上一次请求
					switch_windows = "<Tab>",
					reverse_switch_windows = "<S-Tab>",
				},
			},
			hints = { enabled = true },
			windows = {
				position = "right",
				wrap = true, -- 启用自动换行，避免长行割裂边框
				width = 35, -- 稍宽一点，减少换行
				height = 30,
				fillchars = "eob: ",
				sidebar_header = {
					enabled = true,
					align = "center",
					rounded = true, -- 使用圆角，符合官方演示
				},
				-- 官方默认的 spinner 动画
				spinner = {
					editing = {
						"⡀",
						"⠄",
						"⠂",
						"⠁",
						"⠈",
						"⠐",
						"⠠",
						"⢀",
						"⣀",
						"⢄",
						"⢂",
						"⢁",
						"⢈",
						"⢐",
						"⢠",
						"⣠",
						"⢤",
						"⢢",
						"⢡",
						"⢨",
						"⢰",
						"⣰",
						"⢴",
						"⢲",
						"⢱",
						"⢸",
						"⣸",
						"⢼",
						"⢺",
						"⢹",
						"⣹",
						"⢽",
						"⢻",
						"⣻",
						"⢿",
						"⣿",
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
					border = "rounded", -- 使用圆角边框
					start_insert = true,
				},
				ask = {
					floating = false,
					border = "rounded", -- 使用圆角边框
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
			-- 注意: disabled_tools 仅影响 Avante 本地工具，不影响 ACP provider (gemini-cli)
			-- ACP 模式下的工具控制需要在 gemini-cli 的 settings.json 中配置
			-- disabled_tools = {
			-- 	"write_to_file",    -- 禁用整体写入工具
			-- 	"create",           -- 禁用创建文件工具
			-- 	"insert",           -- 禁用插入工具
			-- 	"write_global_file", -- 禁用全局文件写入
			-- },
		},
		-- 构建命令 + 自动应用补丁
		build = function()
			-- 先执行原始构建
			if vim.fn.has("win32") ~= 0 then
				vim.fn.system("powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false")
			else
				vim.fn.system("make")
			end
			-- 然后应用补丁
			local patch_script = vim.fn.stdpath("config") .. "/scripts/patch-avante.sh"
			if vim.fn.filereadable(patch_script) == 1 then
				vim.fn.system("bash " .. patch_script)
				vim.notify("[Avante] 补丁已自动应用", vim.log.levels.INFO)
			end
		end,
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
					default = {
						-- 禁用详细日志，避免非图像剪贴板时显示警告
						verbose = false,
						-- recommended settings
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows/WSL users
						use_absolute_path = true,
						-- 支持更多图像格式 (默认只有 jpeg, jpg, png)
						formats = { "jpeg", "jpg", "png", "bmp", "gif", "webp" },
					},
				},
				keys = {
					{ "<leader>pi", "<cmd>PasteImage<cr>", desc = "Paste image from clipboard" },
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{
				"<leader>aA",
				function()
					require("avante.api").ask()
				end,
				desc = "avante: ask",
				mode = { "n", "v" },
			},
			{
				"<leader>aR",
				function()
					require("avante.api").refresh()
				end,
				desc = "avante: refresh",
			},
			{
				"<leader>aE",
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = "v",
			},
			{
				"<leader>aS",
				function()
					-- 尝试多种方式停止输出
					local ok, avante = pcall(require, "avante")
					if ok then
						-- 尝试使用 api.stop()
						local api_ok = pcall(function()
							require("avante.api").stop()
						end)
						if not api_ok then
							-- 备用: 发送中断信号给 ACP 进程
							pcall(function()
								local acp = require("avante.providers.acp")
								if acp and acp.abort then
									acp.abort()
								end
							end)
						end
						vim.notify("[Avante] 已停止输出", vim.log.levels.INFO)
					end
				end,
				desc = "avante: stop output",
				mode = { "n", "i" },
			},
			{
				"<leader>at",
				function()
					require("avante.api").toggle()
				end,
				desc = "avante: toggle sidebar",
			},
		},
		config = function(_, opts)
			require("avante").setup(opts)

			-- 为 Avante 窗口设置透明度和样式
			-- 使用 BufEnter 而不是 FileType，并延迟执行以确保窗口完全初始化
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "*",
				callback = function()
					local ft = vim.bo.filetype
					if ft == "Avante" or ft == "AvanteInput" or ft == "AvanteSelectedFiles" then
						vim.schedule(function()
							-- 确保窗口有效
							if not vim.api.nvim_win_is_valid(0) then
								return
							end

							-- 设置窗口透明度 (0=不透明, 100=完全透明)
							vim.wo.winblend = 10

							-- 强制设置换行选项
							vim.wo.wrap = true
							vim.wo.linebreak = true -- 在单词边界换行
							vim.wo.breakindent = true -- 换行时保持缩进
							vim.wo.cursorline = false -- 禁用光标行高亮
							vim.wo.sidescrolloff = 0 -- 禁用水平滚动偏移
						end)
					end
				end,
			})

			-- 设置自定义高亮（只需要设置一次）
			vim.api.nvim_set_hl(0, "AvanteTitle", { fg = "#7dcfff", bold = true })
			vim.api.nvim_set_hl(0, "AvanteConflictCurrent", { bg = "#2e4a3a" })
			vim.api.nvim_set_hl(0, "AvanteConflictIncoming", { bg = "#2d3f5a" })
		end,
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
