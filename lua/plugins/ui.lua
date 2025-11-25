local bo = vim.bo
local fn = vim.fn

-- 不规则空白检测函数
local function irregularWhitespace()
	-- USER CONFIG
	-- filetypes and the number of spaces they use. Omit or set to nil to use tabs for that filetype.
	local spaceFiletypes = { python = 4, yaml = 2 }
	local ignoredFiletypes = { "css", "markdown", "gitcommit" }
	local linebreakType = "unix" ---@type "unix" | "mac" | "dos"

	-- vars & guard
	local usesSpaces = bo.expandtab
	local usesTabs = not bo.expandtab
	local brUsed = bo.fileformat
	local ft = bo.filetype
	local width = bo.tabstop
	if vim.tbl_contains(ignoredFiletypes, ft) or fn.mode() ~= "" then
		return ""
	end

	-- non-default indentation setting (e.g. changed via indent-o-matic)
	local nonDefaultSetting = ""
	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	if (usesSpaces and not vim.tbl_contains(spaceFtsOnly, ft)) or (usesSpaces and width ~= spaceFiletypes[ft]) then
		nonDefaultSetting = " " .. tostring(width) .. "󱁐  "
	elseif usesTabs and vim.tbl_contains(spaceFtsOnly, ft) then
		nonDefaultSetting = " 󰌒 " .. tostring(width)
	end

	-- wrong or mixed indentation
	local hasTabs = fn.search("^\t", "nw") > 0
	local hasSpaces = fn.search("^ ", "nw") > 0
	-- exception, jsdocs: space not followed by "*"
	if bo.filetype == "javascript" then
		hasSpaces = fn.search([[^ \(\*\)\@!]], "nw") > 0
	end
	local wrongIndent = ""
	if usesTabs and hasSpaces then
		wrongIndent = " 󱁐 "
	elseif usesSpaces and hasTabs then
		wrongIndent = " 󰌒 "
	elseif hasTabs and hasSpaces then
		wrongIndent = " 󱁐 + 󰌒 "
	end

	-- line breaks
	local linebreakIcon = ""
	if brUsed ~= linebreakType then
		if brUsed == "unix" then
			linebreakIcon = " 󰌑 "
		elseif brUsed == "mac" then
			linebreakIcon = " 󰌑 "
		elseif brUsed == "dos" then
			linebreakIcon = " 󰌑 "
		end
	end

	return nonDefaultSetting .. wrongIndent .. linebreakIcon
end

-- 字符统计函数
local function count_eng_zh_chars(text)
	local eng_count = 0
	local zh_count = 0
	local digit_count = 0

	if not text or text == "" then
		return 0, 0, 0
	end

	-- Count English letters (ASCII a-z, A-Z)
	eng_count = select(2, text:gsub("[a-zA-Z]", ""))

	-- Count digits (0-9)
	digit_count = select(2, text:gsub("[0-9]", ""))

	-- Count likely Chinese characters in the CJK Unified Ideographs block (U+4E00 to U+9FFF)
	zh_count = select(2, text:gsub("[\xE4-\xE9][\x80-\xBF][\x80-\xBF]", ""))

	return eng_count, zh_count, digit_count
end

-- 获取可视选择文本
local function get_visual_selection()
	local mode = vim.fn.mode()

	-- 检查是否在可视模式下
	if not (mode == "v" or mode == "V" or mode == "\22") then
		return ""
	end

	-- 获取起始和结束位置
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	-- 解包位置信息
	local s_line, s_col = start_pos[2], start_pos[3]
	local e_line, e_col = end_pos[2], end_pos[3]

	-- 确保起始位置在结束位置之前
	if s_line > e_line or (s_line == e_line and s_col > e_col) then
		s_line, e_line = e_line, s_line
		s_col, e_col = e_col, s_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)
	if #lines == 0 then
		return ""
	end

	-- 处理选择的文本
	if #lines == 1 then
		-- 单行选择
		return lines[1]:sub(s_col, e_col)
	else
		-- 多行选择
		lines[1] = lines[1]:sub(s_col)
		lines[#lines] = lines[#lines]:sub(1, e_col)
		return table.concat(lines, "\n")
	end
end

-- 选择计数显示
local function selectionCount()
	local mode = vim.fn.mode()

	-- 只在可视模式下显示计数
	if not (mode == "v" or mode == "V" or mode == "\22") then
		return ""
	end

	local text = get_visual_selection()
	if text == "" then
		return ""
	end

	local eng_count, zh_count, digit_count = count_eng_zh_chars(text)
	local total_chars = vim.fn.strchars(text)
	local other_chars = total_chars - eng_count - zh_count - digit_count

	-- 返回格式化的计数信息，使用更美观的图标和格式
	local result_parts = {}

	if eng_count > 0 then
		table.insert(result_parts, string.format("🔤%d", eng_count))
	end

	if zh_count > 0 then
		table.insert(result_parts, string.format("🀄%d", zh_count))
	end

	if digit_count > 0 then
		table.insert(result_parts, string.format("🔢%d", digit_count))
	end

	if other_chars > 0 then
		table.insert(result_parts, string.format("📝%d", other_chars))
	end

	if #result_parts == 0 then
		return string.format("📄%d", total_chars)
	end

	return table.concat(result_parts, " ")
end

return {
	-- 颜色方案
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			style = "night",
			transparent = true,
			terminal_colors = true,
			styles = {
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				sidebars = "transparent",
				floats = "transparent",
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},

	-- 状态栏
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "f-person/git-blame.nvim" },
		config = function()
			local git_blame = require("gitblame")
			vim.g.gitblame_display_virtual_text = 0

			require("lualine").setup({
				options = {
					theme = "tokyonight",
					transparent = true,
					component_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = {
						{ "filename", path = 1 },
						{ "filesize" },
						{
							function()
								local mode = vim.fn.mode()
								if mode == "v" or mode == "V" or mode == "\22" then
									-- 可视模式下显示选择区域的字符统计
									return selectionCount()
								else
									-- 普通模式下显示整个文件的字符统计
									local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
									local eng_count, zh_count, digit_count = count_eng_zh_chars(content)
									local total_chars = vim.fn.strchars(content)
									local other_chars = total_chars - eng_count - zh_count - digit_count

									local result_parts = {}

									if eng_count > 0 then
										table.insert(result_parts, string.format("🔤%d", eng_count))
									end

									if zh_count > 0 then
										table.insert(result_parts, string.format("🀄%d", zh_count))
									end

									if digit_count > 0 then
										table.insert(result_parts, string.format("🔢%d", digit_count))
									end

									if other_chars > 0 then
										table.insert(result_parts, string.format("📝%d", other_chars))
									end

									if #result_parts == 0 then
										return string.format("📄%d", total_chars)
									end

									return table.concat(result_parts, " ")
								end
							end,
							color = { fg = "#8be9fd" },
						},
						{ git_blame.get_current_blame_text, cond = git_blame.is_blame_text_available },
					},
					lualine_x = {
						"os.date('%Y-%m-%d %H:%M:%S')",
						"encoding",
						"fileformat",
						"filetype",
						{
							"diagnostics",
							symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
						},
						{ irregularWhitespace },
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},

	-- 文件树
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = "NvimTreeToggle",
		keys = { { "<leader>e", "<CMD>NvimTreeToggle<CR>" } },
		config = function()
			local function my_on_attach(bufnr)
				local api = require("nvim-tree.api")

				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				-- default mappings
				api.config.mappings.default_on_attach(bufnr)

				-- custom mappings
				vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
				vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
				vim.keymap.set("n", "o", api.node.open.vertical, opts("Open: Vertical Split"))
			end

			require("nvim-tree").setup({
				sort_by = "case_sensitive",
				hijack_cursor = true,
				system_open = {
					cmd = "open",
				},
				view = {
					width = 30,
					side = "left",
					number = false,
					relativenumber = false,
					signcolumn = "yes",
				},
				actions = {
					open_file = {
						quit_on_open = false,
						resize_window = true,
					},
				},
				filters = {
					dotfiles = false,
					custom = { "node_modules" },
				},
				git = {
					enable = true,
					ignore = false,
				},
				update_focused_file = {
					enable = true,
					update_root = true,
				},
				on_attach = my_on_attach,
				renderer = {
					root_folder_label = false,
					highlight_git = true,
					indent_markers = { enable = true },
					special_files = {},
					icons = {
						show = {
							file = true,
							folder = true,
							folder_arrow = true,
							git = true,
						},
						glyphs = {
							default = "󰈚",
							symlink = "",
							bookmark = "󰆤",
							modified = "●",
							-- folder = {
							-- 	arrow_closed = "",
							-- 	arrow_open = "",
							-- 	default = "󰉋",
							-- 	open = "",
							-- 	empty = "",
							-- 	empty_open = "",
							-- 	symlink = "",
							-- 	symlink_open = "",
							-- },
							git = {
								unstaged = "✗",
								staged = "✓",
								unmerged = "",
								renamed = "➜",
								untracked = "★",
								deleted = "",
								ignored = "◌",
							},
						},
						webdev_colors = true,
						git_placement = "before",
						padding = " ",
						symlink_arrow = " ➛ ",
					},
					highlight_opened_files = "none",
					root_folder_modifier = ":~",
					add_trailing = false,
				},
			})
		end,
	},

	-- Git blame
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = {
			enabled = true,
			message_template = " <summary> • <date> • <author> • <<sha>>",
			date_format = "%m-%d-%Y %H:%M:%S",
			virtual_text_column = 1,
		},
	},

	-- 错误列表
	{
		"folke/trouble.nvim",
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
			keys = {
				["<esc>"] = "close",
			},
		},
	},

	-- 缓冲区标签页
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "<leader>[", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<leader>]", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
			{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
			{ "H", "0", mode = { "n" } },
			{ "L", "$", mode = { "n" } },
		},
		opts = {
			options = {
				close_command = function(n)
					if package.loaded["snacks"] then
						Snacks.bufdelete(n)
					else
						vim.cmd("bdelete " .. n)
					end
				end,
				right_mouse_command = function(n)
					if package.loaded["snacks"] then
						Snacks.bufdelete(n)
					else
						vim.cmd("bdelete " .. n)
					end
				end,
				separator_style = "slant",
				indicator = {
					style = "underline",
				},
				buffer_close_icon = "󰅖",
				modified_icon = "● ",
				close_icon = " ",
				left_trunc_marker = " ",
				right_trunc_marker = " ",
				diagnostics = "nvim_lsp",
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				numbers = function(opts)
					return string.format(" %s/%s", vim.fn.tabpagenr(), opts.ordinal)
				end,
				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
				pick = {
					alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
				},
				max_name_length = 18,
				tab_size = 18,
				offsets = {
					{
						filetype = "NvimTree",
						text = "Explorer",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
			highlights = {
				background = {
					bg = "NONE",
				},
				buffer_selected = {
					bg = "NONE",
				},
				buffer_visible = {
					bg = "NONE",
				},
				close_button = {
					bg = "NONE",
				},
				close_button_visible = {
					bg = "NONE",
				},
				close_button_selected = {
					bg = "NONE",
				},
				fill = {
					bg = "NONE",
				},
				separator = {
					bg = "NONE",
				},
				separator_selected = {
					bg = "NONE",
				},
				separator_visible = {
					bg = "NONE",
				},
				tab = {
					bg = "NONE",
				},
				tab_selected = {
					bg = "NONE",
				},
				tab_close = {
					bg = "NONE",
				},
				duplicate_selected = {
					bg = "NONE",
				},
				duplicate_visible = {
					bg = "NONE",
				},
				duplicate = {
					bg = "NONE",
				},
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(require, "bufferline")
					end)
				end,
			})
		end,
	},

	-- 标签页作用域
	{
		"tiagovla/scope.nvim",
		config = function()
			require("scope").setup({})
		end,
		keys = {
			{ "<M-n>", "<CMD>tabnext<CR>" },
			{ "<M-p>", "<CMD>tabprevious<CR>" },
		},
	},

	-- 通知系统
	-- ...existing code...
	-- 通知系统
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			lsp = {
				override = {
					["cmp.entry.get_documentation"] = true,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "Agent service not initialized" },
						},
					},
					opts = { skip = true },
				},
			},
			presets = {
				bottom_search = false, -- 禁用底部搜索，使用弹出式
				command_palette = true, -- 启用命令面板
				long_message_to_split = true,
			},
			cmdline = {
				enabled = true, -- 启用命令行
				view = "cmdline_popup", -- 恢复使用弹出式命令行
				opts = {}, -- 全局cmdline选项
				format = {
					-- 命令模式
					cmdline = { pattern = "^:", lang = "vim" },
					-- 搜索模式（向下搜索）
					search_down = { kind = "search", pattern = "^/", lang = "regex" },
					-- 搜索模式（向上搜索）
					search_up = { kind = "search", pattern = "^%?", lang = "regex" },
					-- 过滤模式
					filter = { pattern = "^:%s*!", lang = "bash" },
					-- Lua模式
					lua = { pattern = "^:%s*lua%s+", lang = "lua" },
					-- 帮助模式
					help = { pattern = "^:%s*he?l?p?%s+" },
					-- 输入模式
					input = {},
				},
			},
			messages = {
				-- 注意：如果启用messages，某些内容可能会重复显示
				enabled = true, -- 启用消息
				view = "notify", -- 默认视图
				view_error = "notify", -- 错误消息视图
				view_warn = "notify", -- 警告消息视图
				view_history = "messages", -- :messages的视图
				view_search = "virtualtext", -- 搜索计数消息
			},
			popupmenu = {
				enabled = true, -- 启用弹出菜单
				backend = "nui", -- 使用原生后端显示补全
				kind_icons = {}, -- 禁用图标
			},
			-- 自定义视图配置
			views = {
				cmdline_popup = {
					position = {
						row = "50%", -- 垂直居中
						col = "50%", -- 水平居中
					},
					size = {
						width = 60, -- 命令行宽度
						height = "auto",
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					filter_options = {},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 20, -- 增加命令框透明度
					},
				},
				popupmenu = {
					relative = "editor", -- 相对于编辑器定位
					position = {
						row = "70%", -- 位置在屏幕下方70%处，确保在命令框下方
						col = "50%", -- 水平居中
					},
					size = {
						width = 60,
						height = 15, -- 显示更多选项
					},
					border = {
						style = "rounded",
						padding = { 0, 1 },
					},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 20, -- 增加透明度
					},
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},

	-- 图标
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
				[".gitignore"] = { glyph = "", hl = "MiniIconsOrange" },
				[".env"] = { glyph = "", hl = "MiniIconsYellow" },
				["README.md"] = { glyph = "", hl = "MiniIconsBlue" },
				["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
				["tsconfig.json"] = { glyph = "", hl = "MiniIconsBlue" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
				git = { glyph = "", hl = "MiniIconsOrange" },
				lua = { glyph = "", hl = "MiniIconsBlue" },
				python = { glyph = "", hl = "MiniIconsYellow" },
				javascript = { glyph = "", hl = "MiniIconsYellow" },
				typescript = { glyph = "", hl = "MiniIconsBlue" },
				rust = { glyph = "", hl = "MiniIconsRed" },
				go = { glyph = "", hl = "MiniIconsCyan" },
				json = { glyph = "", hl = "MiniIconsYellow" },
				yaml = { glyph = "", hl = "MiniIconsRed" },
				markdown = { glyph = "", hl = "MiniIconsBlue" },
			},
			directory = {
				[".git"] = { glyph = "", hl = "MiniIconsOrange" },
				[".github"] = { glyph = "", hl = "MiniIconsGrey" },
				["node_modules"] = { glyph = "", hl = "MiniIconsGreen" },
				["src"] = { glyph = "", hl = "MiniIconsBlue" },
				["lib"] = { glyph = "", hl = "MiniIconsPurple" },
				["config"] = { glyph = "", hl = "MiniIconsYellow" },
				["docs"] = { glyph = "", hl = "MiniIconsBlue" },
				["test"] = { glyph = "󰙨", hl = "MiniIconsRed" },
				["tests"] = { glyph = "󰙨", hl = "MiniIconsRed" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
		config = function(_, opts)
			require("mini.icons").setup(opts)
		end,
	},
}
