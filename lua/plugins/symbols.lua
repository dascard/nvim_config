-- LSP 符号列表插件
return {
	{
		"stevearc/aerial.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},
		opts = {
			-- 基本配置
			backends = { "lsp", "treesitter", "markdown", "asciidoc", "man" },
			
			-- 布局配置
			layout = {
				max_width = { 40, 0.2 }, -- 最大宽度：40字符或20%屏幕宽度
				width = nil, -- 自动宽度
				min_width = 20, -- 最小宽度
				win_opts = {
					winblend = 25, -- 透明度，与其他UI保持一致
				},
				default_direction = "right", -- 默认在右侧显示
				placement = "window", -- 在窗口中显示
				preserve_equality = true, -- 保持窗口等宽
			},
			
			-- 显示配置
			attach_mode = "window", -- 附加到窗口
			close_automatic_events = { "unsupported" }, -- 自动关闭事件
			keymaps = {
				["?"] = "actions.show_help",
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.jump",
				["<2-LeftMouse>"] = "actions.jump",
				["<C-v>"] = "actions.jump_vsplit",
				["<C-s>"] = "actions.jump_split",
				["p"] = "actions.scroll",
				["<C-j>"] = "actions.down_and_scroll",
				["<C-k>"] = "actions.up_and_scroll",
				["{"] = "actions.prev",
				["}"] = "actions.next",
				["[["] = "actions.prev_up",
				["]]"] = "actions.next_up",
				["q"] = "actions.close",
				["o"] = "actions.tree_toggle",
				["za"] = "actions.tree_toggle",
				["O"] = "actions.tree_toggle_recursive",
				["zA"] = "actions.tree_toggle_recursive",
				["l"] = "actions.tree_open",
				["zo"] = "actions.tree_open",
				["L"] = "actions.tree_open_recursive",
				["zO"] = "actions.tree_open_recursive",
				["h"] = "actions.tree_close",
				["zc"] = "actions.tree_close",
				["H"] = "actions.tree_close_recursive",
				["zC"] = "actions.tree_close_recursive",
				["zr"] = "actions.tree_increase_fold_level",
				["zR"] = "actions.tree_open_all",
				["zm"] = "actions.tree_decrease_fold_level",
				["zM"] = "actions.tree_close_all",
				["zx"] = "actions.tree_sync_folds",
				["zX"] = "actions.tree_sync_folds",
			},
			
			-- 过滤和显示选项
			filter_kind = {
				"Class",
				"Constructor", 
				"Enum",
				"Function",
				"Interface",
				"Module",
				"Method",
				"Struct",
				"Type",
				"Variable",
				"Constant",
				"Field",
				"Property",
			},
			
			-- 图标配置
			icons = {
				Array = "󰅪",
				Boolean = "⊨",
				Class = "󰌗",
				Constructor = "",
				Key = "󰌆",
				Namespace = "󰅪",
				Null = "NULL",
				Number = "#",
				Object = "󰀚",
				Package = "󰏗",
				Property = "",
				Reference = "",
				Snippet = "",
				String = "󰀬",
				TypeParameter = "󰊄",
				Unit = "",
				-- LSP 符号
				File = "󰈙",
				Module = "",
				Function = "󰊕",
				Method = "",
				Variable = "󰀫",
				Constant = "󰏿",
				Field = "",
				Interface = "",
				Enum = "",
				Struct = "󰌗",
				EnumMember = "",
				Event = "",
				Operator = "󰆕",
			},
			
			-- 突出显示配置
			highlight_mode = "split_width", -- 突出显示模式
			highlight_closest = true, -- 突出显示最近的符号
			highlight_on_hover = false, -- 悬停时不突出显示
			highlight_on_jump = 300, -- 跳转时突出显示时间(ms)
			
			-- 自动打开/关闭
			open_automatic = false, -- 不自动打开
			close_on_select = false, -- 选择时不关闭
			
			-- 更新事件
			update_events = "TextChanged,InsertLeave", -- 更新触发事件
			
			-- 显示指南线
			show_guides = true,
			guides = {
				mid_item = "├─",
				last_item = "└─",
				nested_top = "│ ",
				whitespace = "  ",
			},
			
			-- 浮动窗口配置
			float = {
				border = "rounded",
				relative = "editor",
				max_height = 0.9,
				height = nil,
				min_height = { 8, 0.1 },
				override = function(conf, source_winid)
					conf.anchor = "NE"
					conf.col = vim.api.nvim_win_get_width(source_winid)
					conf.row = 0
					return conf
				end,
			},
			
			-- Treesitter 配置
			treesitter = {
				update_delay = 300, -- 更新延迟
			},
			
			-- Markdown 配置
			markdown = {
				update_delay = 300,
			},
			
			-- 导航配置
			nav = {
				border = "rounded",
				max_height = 0.9,
				min_height = { 10, 0.1 },
				max_width = 0.5,
				min_width = { 0.2, 20 },
				win_opts = {
					cursorline = true,
					winblend = 25, -- 透明度
				},
			},
		},
		
		config = function(_, opts)
			require("aerial").setup(opts)
			
			-- 设置快捷键
			vim.keymap.set("n", "<F3>", "<cmd>AerialToggle right<CR>", { 
				desc = "Toggle LSP Symbols Panel", 
				silent = true 
			})
			
			-- 可选的额外快捷键
			vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle<CR>", { 
				desc = "Toggle Symbols Panel", 
				silent = true 
			})
			
			vim.keymap.set("n", "<leader>A", "<cmd>AerialNavToggle<CR>", { 
				desc = "Toggle Symbols Navigation", 
				silent = true 
			})
			
			-- 设置 LSP 符号相关的高亮组
			vim.api.nvim_create_autocmd("ColorScheme", {
				pattern = "*",
				callback = function()
					-- 设置 Aerial 窗口透明度
					vim.api.nvim_set_hl(0, "AerialNormal", { bg = "NONE" })
					vim.api.nvim_set_hl(0, "AerialBorder", { bg = "NONE" })
					vim.api.nvim_set_hl(0, "AerialLine", { bg = "NONE" })
				end,
			})
		end,
	},
}
