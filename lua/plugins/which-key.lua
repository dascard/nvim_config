local icons = require("utils.icons")

return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		icons = {
			breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
			separator = "󰁔", -- symbol used between a key and it's label
			group = "+", -- symbol prepended to a group
		},
		win = {
			-- don't allow the popup to overlap with the cursor
			no_overlap = true,
			-- width = 1,
			-- height = { min = 4, max = 25 },
			-- col = 0,
			-- row = math.huge,
			border = "rounded",
			padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
			title = true,
			title_pos = "center",
			zindex = 1000,
			wo = {
				winblend = 0, -- 增加透明度，使其更好地贴合背景
			},
		},
		layout = {
			height = { min = 4, max = 30 }, -- 增加最大高度以显示更多快捷键
			width = { min = 20, max = 60 }, -- 增加最大宽度以显示更长的描述
			spacing = 3,                 -- spacing between columns
			align = "left",              -- align columns left, center or right
		},
		show_help = true,              -- show a help message in the command line for using WhichKey
		show_keys = true,              -- show the currently pressed key and its label as a message in the command line
		disable = {
			buftypes = {},
			filetypes = { "TelescopePrompt" },
		},
	},
	config = function(_, opts)
		local wk = require("which-key")
		wk.setup(opts)

		-- 定义按键分组和说明
		wk.add({
			-- 文件操作组
			{ "<leader>f", group = icons.get("ui").File .. " Files", icon = "󰈙" },
			{ "<leader>ff", desc = "Find Files" },
			{ "<leader>fr", desc = "Recent Files" },
			{ "<leader>ft", desc = "New Float Terminal" },

			-- 缓冲区操作组
			{ "<leader>b", group = icons.get("ui").Buffer .. " Buffers", icon = "󰓩" },
			{ "<leader>bp", desc = "Pin Buffer" },
			{ "<leader>bP", desc = "Delete Non-Pinned Buffers" },
			{ "<leader>br", desc = "Delete Right Buffers" },
			{ "<leader>bl", desc = "Delete Left Buffers" },
			{ "<leader>b[", desc = "Previous Buffer" },
			{ "<leader>b]", desc = "Next Buffer" },

			-- 搜索操作组
			{ "<leader>s", group = icons.get("ui").Search .. " Search", icon = "󰍉" },
			{ "<leader>ss", desc = "Search and Replace" },
			{ "<leader>sb", desc = "LSP Symbols" },
			{ "<leader>sB", desc = "LSP Workspace Symbols" },
			{ "<leader>st", desc = "Search TODO" },

			-- Git 操作组
			{ "<leader>g", group = icons.get("git").Git .. " Git", icon = "󰊢" },
			{ "<leader>gd", desc = "Go to Definition" },
			{ "<leader>gD", desc = "Go to Declaration" },
			{ "<leader>gr", desc = "Go to References" },
			{ "<leader>gi", desc = "Go to Implementation" },
			{ "<leader>gy", desc = "Go to Type Definition" },
			{ "<leader>gl", desc = "Git Log" },
			{ "<leader>gb", desc = "Git Branches" },

			-- 调试操作组
			{ "<leader>d", group = icons.get("dap").Play .. " Debug", icon = "" },
			{ "<leader>dp", desc = "Toggle Breakpoint" },
			{ "<leader>dc", desc = "Continue" },
			{ "<leader>dtc", desc = "Run to Cursor" },
			{ "<leader>dT", desc = "Terminate" },
			{ "<leader>di", desc = "Step Into" },
			{ "<leader>do", desc = "Step Out" },
			{ "<leader>dr", desc = "Open REPL" },
			{ "<leader>de", desc = "Run Last" },
			{ "<leader>ds", desc = "Toggle REPL" },
			{ "<leader>dx", desc = "Close REPL" },
			{ "<leader>du", desc = "Toggle Debug UI" },
			{ "<leader>dg", desc = "Search Diagnostics" },

			-- 工作区操作组
			{ "<leader>w", group = icons.get("ui").Window .. " Workspace", icon = "" },
			{ "<leader>wa", desc = "Add Workspace Folder" },
			{ "<leader>wr", desc = "Remove Workspace Folder" },
			{ "<leader>wl", desc = "List Workspace Folders" },

			-- LSP 和代码操作组
			{ "<leader>c", group = icons.get("ui").CodeAction .. " Code", icon = "󰌵" },
			{ "<leader>ca", desc = "Code Action" },
			{ "<leader>cf", desc = "Quick Fix" },

			-- 重命名操作组
			{ "<leader>r", group = icons.get("ui").Pencil .. " Rename", icon = "󰏫" },
			{ "<leader>rn", desc = "Rename Symbol" },

			-- 终端操作组
			{ "<leader>t", group = icons.get("kind").Terminal .. " Terminal/Test", icon = "" },
			{ "<leader>tt", desc = "Run Current File Test" },
			{ "<leader>tT", desc = "Run All Tests" },
			{ "<leader>tr", desc = "Run Recent Test" },
			{ "<leader>tl", desc = "Run Last Test" },
			{ "<leader>ts", desc = "Toggle Test Summary" },
			{ "<leader>to", desc = "Show Test Output" },
			{ "<leader>tO", desc = "Show Test Output Panel" },
			{ "<leader>tw", desc = "Watch Mode" },

			-- 任务管理操作组
			{ "<leader>o", group = icons.get("ui").Play .. " Overseer", icon = "" },
			{ "<leader>ow", desc = "Toggle Task List" },
			{ "<leader>oo", desc = "Run Task" },
			{ "<leader>oq", desc = "Quick Action Recent Task" },
			{ "<leader>oi", desc = "Overseer Info" },
			{ "<leader>ob", desc = "Task Builder" },
			{ "<leader>ot", desc = "Task Actions" },
			{ "<leader>oc", desc = "Clear Cache" },

			-- 项目操作组
			{ "<leader>p", group = icons.get("ui").Project .. " Project", icon = "" },
			{ "<leader>pr", desc = "Open Project List" },

			-- TODO 操作组
			{ "<leader>x", group = icons.get("ui").List .. " TODO/Trouble", icon = "" },
			{ "<leader>xt", desc = "TODO List (Trouble)" },
			{ "<leader>xT", desc = "TODO/FIX/FIXME List" },

			-- 通知和其他功能组
			{ "<leader>n", group = icons.get("ui").Newspaper .. " Notifications", icon = "" },
			{ "<leader>nf", desc = "Notification History" },

			-- UI 控制组
			{ "<leader>u", group = icons.get("ui").Gear .. " UI", icon = "" },
			{ "<leader>ud", desc = "Undo History" },

			-- 快速操作组
			{ "<leader>q", group = icons.get("ui").List .. " QuickFix", icon = "" },
			{ "<leader>qf", desc = "QuickFix Window" },

			-- 其他单个操作
			{ "<leader>=", desc = "Format Code", icon = "󰉣" },
			{ "<leader>l", desc = "Trigger Lint", icon = "󰁨" },
			{ "<leader>e", desc = "Toggle File Explorer", icon = "󰙅" },
			{ "<leader>k", desc = "Close Float Terminal", icon = "" },
			{ "<leader>K", desc = "Preview Fold", icon = "󰂓" },
			{ "<leader>Z", desc = "Zen Mode", icon = "󰚀" },
			{ "<leader>/", desc = "Toggle Comment", icon = "󰅺" },
			{ "<leader>?", desc = "Toggle Block Comment", icon = "󰅺" },

			-- AI/Copilot 操作组
			{ "<leader>a", group = "🤖 AI (Copilot)", icon = "🤖" },

			-- 单键映射说明
			{ "gd", desc = "Go to Definition", icon = "󰈮" },
			{ "gr", desc = "Go to References", icon = "󰈇" },
			{ "gi", desc = "Go to Implementation", icon = "󰈮" },
			{ "K", desc = "Hover Info", icon = "󰋗" },
			{ "H", desc = "Go to Line Start", icon = "󰁍" },
			{ "L", desc = "Go to Line End", icon = "󰁔" },
			{ "J", desc = "Move Down 15 Lines", icon = "󰁆" },
			{ "Q", desc = "Format Paragraph", icon = "󰉣" },

			-- 功能键说明
			{ "<F5>", desc = "Start/Continue Debug", icon = "" },
			{ "<F6>", desc = "Run Last Debug", icon = "↻" },
			{ "<F10>", desc = "Toggle Transparency (Neovide)", icon = "󰂖" },
			{ "<F11>", desc = "Toggle Fullscreen (Neovide)", icon = "󰊓" },
			{ "<F12>", desc = "Toggle Float Terminal", icon = "" },

			-- 插入模式映射
			{ "jk", desc = "Exit Insert Mode", mode = "i", icon = "󰅖" },
			{ "<leader>a", desc = "Exit Insert and Go to End", mode = "i", icon = "󰁍" },

			-- 可视模式映射
			{ "<C-j>", desc = "Move Selection Down", mode = "v", icon = "󰁆" },
			{ "<C-k>", desc = "Move Selection Up", mode = "v", icon = "󰁞" },
			{ "<Tab>", desc = "Indent Selection", mode = "v", icon = "󰉶" },
			{ "<S-Tab>", desc = "Unindent Selection", mode = "v", icon = "󰉵" },

			-- 窗口导航
			{ "<Left>", desc = "Move to Left Window", icon = "󰁍" },
			{ "<Right>", desc = "Move to Right Window", icon = "󰁔" },
			{ "<Up>", desc = "Move to Upper Window", icon = "󰁞" },
			{ "<Down>", desc = "Move to Lower Window", icon = "󰁆" },

			-- Flash 跳转
			{ "s", desc = "Flash Jump", icon = "󰳽" },
			{ "S", desc = "Flash Treesitter", icon = "󰳽" },

			-- TODO 导航
			{ "]t", desc = "Next TODO", icon = "󰁔" },
			{ "[t", desc = "Previous TODO", icon = "󰁍" },

			-- 缓冲区导航
			{ "<S-h>", desc = "Previous Buffer", icon = "󰁍" },
			{ "<S-l>", desc = "Next Buffer", icon = "󰁔" },
			{ "[B", desc = "Move Buffer Left", icon = "󰁍" },
			{ "]B", desc = "Move Buffer Right", icon = "󰁔" },

			-- 标签页导航
			{ "<M-n>", desc = "Next Tab", icon = "󰁔" },
			{ "<M-p>", desc = "Previous Tab", icon = "󰁍" },

			-- 特殊命令
			{ "git", desc = "Open Lazygit", icon = "󰊢" },
			{ "\\t", desc = "Select and Run Task", icon = "" },
			{ "\\s", desc = "Evaluate Expression (Debug)", icon = "󰩫" },

			-- Copilot AI
			{ "<C-]>", desc = "Next Copilot Suggestion", mode = "i", icon = "" },
			{ "<C-}>", desc = "Previous Copilot Suggestion", mode = "i", icon = "" },

			-- 代码折叠
			{ "zO", desc = "Open All Folds", icon = "󰂙" },
			{ "zC", desc = "Close All Folds", icon = "󰂕" },
			{ "zr", desc = "Open All Folds Except Current", icon = "󰂚" },

			-- 搜索快捷键
			{ "<M-k>", desc = "Search Keymaps", icon = "󰌌" },
			{ "<c-f>", desc = "Ripgrep Search", icon = "󰍉" },

			-- 调试特殊键
			{ "<space><space>", desc = "Step Over (Debug)", icon = "󰆷" },
		})
	end,
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer Local Keymaps (which-key)",
		},
	},
}
