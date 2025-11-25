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
	{
		"folke/sidekick.nvim",
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
				"<tab>",
				function()
					-- if there is a next edit, jump to it, otherwise apply it if any
					if not require("sidekick").nes_jump_or_apply() then
						return "<Tab>" -- fallback to normal tab
					end
				end,
				expr = true,
				desc = "Goto/Apply Next Edit Suggestion",
			},
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
