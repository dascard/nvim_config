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
					accept = "<C-j>", -- Ctrl+Y 接受 Copilot 建议
					accept_word = "<C-l>", -- Ctrl+L 接受单词
					accept_line = "<M-l>", -- Alt+L 接受行
					next = "<M-]>",   -- Alt+] 下一个建议
					prev = "<M-[>",   -- Alt+[ 上一个建议
					dismiss = "<C-e>", -- Ctrl+E 关闭建议
				},
			},
			panel = {
				enabled = true,
				auto_refresh = true,
				keymap = {
					jump_prev = "[[",
					jump_next = "]]",
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

	-- 2. CopilotChat.nvim: Copilot 聊天界面
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		cmd = { "CopilotChat", "CopilotChatToggle", "CopilotChatReset", "CopilotChatAsk", "CopilotChatSelectPrompt" },
		commit = "93110a5",
		dependencies = {
			{ "zbirenbaum/copilot.lua" }, -- 依赖核心 Copilot 插件
			{ "nvim-lua/plenary.nvim" }, -- 常用工具库
			{ "MeanderingProgrammer/render-markdown.nvim" },
		},
		build = "make tiktoken",                                        -- 构建 tiktoken 库用于标记化
		opts = function()
			local user_name_env = vim.env.USER or vim.env.USERNAME or "User" -- Windows 兼容
			local user_name_capitalized = user_name_env:sub(1, 1):upper() .. user_name_env:sub(2)

			return {
				auto_insert_mode = true,                            -- 进入聊天窗口自动切换到插入模式
				question_header = "  " .. user_name_capitalized .. " ", -- 提问标头
				answer_header = "  Copilot ",                       -- 回答标头
				debug = false,                                      -- 调试模式
				show_help = true,                                   -- 显示帮助信息
				model = "gemini-2.5-pro",
				-- 中文预设提示词
				prompts = {
					Explain = {
						prompt = "请使用中文逐步解释当前选中的代码片段的功能和逻辑，并为关键部分添加注释。",
					},
					Review = {
						prompt = "请仔细检查这段代码，指出潜在的bug、不优雅的实现、性能问题或不符合最佳实践的地方，并用中文提供改进建议。",
					},
					Fix = {
						prompt = "这段代码似乎有问题。请使用中文描述可能存在的问题，并提供一个修复后的代码版本。",
					},
					Optimize = {
						prompt = "请分析这段代码的性能瓶颈或可以优化的地方，并用中文提出具体的优化方案和代码示例。",
					},
					Docs = {
						prompt = "请为这段代码生成中文的文档说明，包括其主要功能、参数（如果有）、返回值（如果有）和使用示例，并为其添加必要的行内注释。",
					},
					Test = {
						prompt = "请为这段代码编写一些重要的测试用例（例如使用Vimscript的vader测试或者目标语言的测试框架），并用中文解释每个测试用例的目的。",
					},
					Commit = {
						prompt = "请根据当前 Git staged 区的更改，生成一条符合规范的中文提交消息（例如 Conventional Commits 格式）。",
						context = "git:staged",
					},
				},
				-- 窗口配置
				window = {
					layout = "vertical", -- 垂直布局
					width = 0.30,      -- 窗口宽度为编辑器的45%
					height = 0.9,      -- 窗口高度为编辑器的90%
					relative = "editor", -- 相对于编辑器定位
					border = "rounded", -- 圆角边框
					title = "Copilot Chat", -- 窗口标题
					win_options = {
						-- signcolumn = "no", -- 不显示符号列
					},
				},
				-- 键盘映射
				mappings = {
					submit = {
						insert = "<C-s>", -- 插入模式下提交
						normal = "<C-s>", -- 正常模式下提交
					},
					close = {
						normal = "q", -- 正常模式下关闭
						insert = "<C-c>", -- 插入模式下关闭
					},
					reset = {
						normal = "<C-r>", -- 正常模式下重置
						insert = "<C-r>", -- 插入模式下重置
					},
				},
			}
		end,
		keys = {
			-- 定义键盘映射
			{
				"<C-s>",
				"<CR>",
				ft = "copilot-chat",
				mode = "i",
				desc = "提交 Prompt (聊天插入模式)",
				remap = true,
			},
			{
				"<leader>ao",
				function()
					pcall(function()
						require("CopilotChat").toggle()
					end)
				end,
				desc = "打开/关闭 Copilot 聊天",
				mode = { "n", "v" },
			},
			{
				"<leader>ar",
				function()
					pcall(function()
						require("CopilotChat").reset()
					end)
				end,
				desc = "重置 Copilot 聊天会话",
				mode = { "n", "v" },
			},
			{
				"<leader>aq",
				function()
					vim.ui.input({ prompt = "快速提问 (Copilot): " }, function(input)
						if input and input ~= "" then
							pcall(function()
								require("CopilotChat").ask(
									input,
									{ selection = require("CopilotChat.select").get_visual_selection() }
								)
							end)
						end
					end)
				end,
				desc = "快速提问 (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				function()
					pcall(function()
						require("CopilotChat").select_prompt({
							selection = require("CopilotChat.select").get_visual_selection(),
						})
					end)
				end,
				desc = "选择预设 Prompt (CopilotChat)",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			-- 检查 CopilotChat 模块是否能够加载
			if not pcall(require, "CopilotChat") then
				vim.notify("[CopilotChat.nvim] Failed to load CopilotChat module.", vim.log.levels.ERROR)
				return
			end
			-- 设置 CopilotChat
			require("CopilotChat").setup(opts)
			require("render-markdown").setup({
				file_types = { "markdown", "copilot-chat" },
			})

			-- Adjust chat display settings
			require("CopilotChat").setup({
				highlight_headers = false,
				separator = "---",
				error_header = "> [!ERROR] Error",
			})

			-- 为 copilot-chat 缓冲区设置本地选项
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				group = vim.api.nvim_create_augroup("MyCopilotChatLocalOpts", { clear = true }),
				callback = function(args)
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
					vim.opt_local.wrap = true
					vim.opt_local.spell = false
					vim.bo[args.buf].bufhidden = "hide"
				end,
			})
		end,
	},

	-- 3. copilot-cmp: 为 nvim-cmp 提供 Copilot 补全源 - 已禁用，改用 COC
	{
		"zbirenbaum/copilot-cmp",
		enabled = false, -- 禁用，因为现在使用 COC.nvim
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
	{
		"folke/edgy.nvim",
		event = "VeryLazy",
		optional = true,             -- 标记为可选插件
		opts = function(_, opts)
			opts = opts or {}          -- 确保 opts 是表格
			opts.right = opts.right or {} -- 初始化右侧窗口列表
			-- 添加 Copilot Chat 到右侧窗口
			table.insert(opts.right, {
				ft = "copilot-chat",
				title = "󰚩 Copilot Chat",
				size = { width = 0.4 },
				-- open_fn = function() pcall(function() require("CopilotChat").open() end) end,
			})

			-- 确保底部窗口列表存在
			opts.bottom = opts.bottom or {}

			return opts
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
		-- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
		-- @module 'render-markdown'
		-- @type render.md.UserConfig
		opts = {},
	}
}
