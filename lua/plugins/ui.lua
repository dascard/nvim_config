local bo = vim.bo
local fn = vim.fn
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
	if vim.tbl_contains(ignoredFiletypes, ft) or fn.mode() ~= "n" or bo.buftype ~= "" then
		return ""
	end

	-- non-default indentation setting (e.g. changed via indent-o-matic)
	local nonDefaultSetting = ""
	local spaceFtsOnly = vim.tbl_keys(spaceFiletypes)
	if (usesSpaces and not vim.tbl_contains(spaceFtsOnly, ft)) or (usesSpaces and width ~= spaceFiletypes[ft]) then
		nonDefaultSetting = " " .. tostring(width) .. "󱁐  "
	elseif usesTabs and vim.tbl_contains(spaceFtsOnly, ft) then
		nonDefaultSetting = " 󰌒 " .. tostring(width)(" ")
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
		wrongIndent = " 󱁐 "
	elseif usesSpaces and hasTabs then
		wrongIndent = " 󰌒 "
	elseif hasTabs and hasSpaces then
		wrongIndent = " 󱁐 + 󰌒 "
	end

	-- line breaks
	local linebreakIcon = ""
	if brUsed ~= linebreakType then
		if brUsed == "unix" then
			linebreakIcon = " 󰌑 "
		elseif brUsed == "mac" then
			linebreakIcon = " 󰌑 "
		elseif brUsed == "dos" then
			linebreakIcon = " 󰌑 "
		end
	end

	return nonDefaultSetting .. wrongIndent .. linebreakIcon
end
-- local function clock()
-- 	if vim.opt.columns:get() < 110 or vim.opt.lines:get() < 25 then
-- 		return ""
-- 	end
--
-- 	local time = tostring(os.date()):sub(12, 16)
-- 	if os.time() % 2 == 1 then
-- 		time = time:gsub(":", " ")
-- 	end -- make the `:` blink
-- 	return time
-- end

-- wrapper to not require navic directly

-- Helper function to count English and likely Chinese characters in a string.
-- Returns two numbers: english_count, chinese_count.
-- Note: The Chinese character counting uses a heuristic based on UTF-8 byte ranges
-- for the main CJK Unified Ideographs block (U+4E00 to U+9FFF). It's not perfectly accurate for all CJK characters or complex Unicode scenarios.
local function count_eng_zh_chars(text)
	local eng_count = 0
	local zh_count = 0

	if not text or text == "" then
		return 0, 0
	end

	-- Count English letters (ASCII a-z, A-Z)
	eng_count = select(2, text:gsub("[a-zA-Z]", ""))

	-- Count likely Chinese characters in the CJK Unified Ideographs block (U+4E00 to U+9FFF)
	-- Matches UTF-8 byte sequences E4..E9 followed by two bytes in 80..BF range.
	-- This is a heuristic.
	zh_count = select(2, text:gsub("[\xE4-\xE9][\x80-\xBF][\x80-\xBF]", ""))

	return eng_count, zh_count
end
local function get_visual_selection()
	-- 获取起始位置和结束位置
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local bufnr = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, end_pos[2], false)

	-- 单行选中
	if #lines == 1 then
		return string.sub(lines[1], start_pos[3], end_pos[3])
	end

	-- 多行选中
	lines[1] = string.sub(lines[1], start_pos[3])
	lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
	return table.concat(lines, "\n")
end
local function selectionCount()
	-- local mode = vim.fn.mode()
	-- if not (mode == "v" or mode == "V" or mode == "\22") then
	-- 	return "" -- 不在选择模式下，不显示
	-- end

	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	-- 解包位置信息
	local s_line, s_col = start_pos[2], start_pos[3]
	local e_line, e_col = end_pos[2], end_pos[3]

	-- 排序
	if s_line > e_line or (s_line == e_line and s_col > e_col) then
		s_line, e_line = e_line, s_line
		s_col, e_col = e_col, s_col
	end

	local lines = vim.api.nvim_buf_get_lines(0, s_line - 1, e_line, false)
	if #lines == 0 then
		return ""
	end

	-- 裁剪列
	lines[1] = lines[1]:sub(s_col)
	lines[#lines] = lines[#lines]:sub(1, e_col)

	local text = table.concat(lines, "\n")
	return count_eng_zh_chars(text)
end
-- local function selectionCount()
-- 	local words = get_visual_selection()
-- 	return count_eng_zh_chars(words)
-- end
-- ============================================================================
-- Lualine Provider for Visual Selection Count
-- ============================================================================

-- Lualine provider function to display character/byte count of visual selection
-- with Eng/Zh breakdown in v/V mode, and byte count in <C-v> mode.
-- ============================================================================
-- Autocmd to force update in Visual mode
-- ============================================================================

-- Autocmd to force Lualine update in Visual modes on CursorMoved

return {
	-- 颜色方案
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000, -- 高优先级确保加载顺序
		opts = {
			style = "night",
			transparent = true,
			terminal_colors = true,
			styles = {
				-- Style to be applied to different syntax groups
				-- Value is any valid attr-list value for `:help nvim_set_hl`
				comments = { italic = true },
				keywords = { italic = true },
				functions = {},
				variables = {},
				-- Background styles. Can be "dark", "transparent" or "normal"
				sidebars = "transparent", -- style for sidebars, see below
				floats = "transparent", -- style for floating windows
			},
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons", "f-person/git-blame.nvim" },
		config = function()
			local git_blame = require("gitblame")
			-- This disables showing of the blame text next to the cursor
			vim.g.gitblame_display_virtual_text = 0
			-- local emptySeparators = { left = "", right = "" }
			-- local bottomSeparators = { left = "", right = "" }
			-- local topSeparators = { left = "", right = "" }
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff" },
					lualine_c = {
						{ "filename", path = 1 }, -- 显示文件名 (带路径)
						{ "filesize" }, -- 显示文件大小
						{
							function()
								-- 仅在非 Visual 模式下显示此组件
								local mode = vim.api.nvim_get_mode().mode
								local total_eng, total_zh
								if not mode:find("[vV\019]") then
									total_eng, total_zh = count_eng_zh_chars(
										table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
									)
									return string.format(
										"英: %d | 汉: %d | 符: %d",
										total_eng,
										total_zh,
										vim.fn.wordcount().chars - total_zh - total_eng
									)
								else
									total_eng, total_zh = selectionCount()
									return string.format(
										"英: %d | 汉: %d | 符: %d",
										total_eng,
										total_zh,
										vim.fn.wordcount().visual_chars - total_zh - total_eng
									)
								end
							end,
							-- 这个组件不需要 CursorMoved 事件，因为它只在模式切换时显示
							-- update_events = { "ModeChanged", "CursorMoved" },
							color = { fg = "#8be9fd" }, -- 例如：设置颜色
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
							symbols = { error = "󰅚 ", warn = " ", info = "󰋽 ", hint = "󰘥 " },
						},
						{ irregularWhitespace },
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"nvim-tree/nvim-tree.lua",
		requires = "nvim-tree/nvim-web-devicons",
		cmd = "NvimTreeToggle",
		keys = { { "<leader>e", "<CMD>NvimTreeToggle<CR>" } },
		config = function()
			require("nvim-tree").setup({
				renderer = {
					-- 隐藏 EndOfBuffer 的 ~ 符号
					root_folder_label = false,
					highlight_git = true,
					indent_markers = { enable = true },
					special_files = {},
					icons = {
						show = {
							-- 隐藏文件树末端的 ~ 符号
							file = false,
							folder = false,
							folder_arrow = false,
							git = false,
						},
					},
					-- 直接禁用 EndOfBuffer 符号渲染
					highlight_opened_files = "none",
					-- 关键配置：隐藏 EndOfBuffer 符号
					root_folder_modifier = ":~",
					add_trailing = false,
				},
			})
		end,
	},
	{
		"f-person/git-blame.nvim",
		-- load the plugin at startup
		event = "VeryLazy",
		-- Because of the keys part, you will be lazy loading this plugin.
		-- The plugin will only load once one of the keys is used.
		-- If you want to load the plugin at startup, add something like event = "VeryLazy",
		-- or lazy = false. One of both options will work.
		opts = {
			-- your configuration comes here
			-- for example
			enabled = true, -- if you want to enable the plugin
			message_template = " <summary> • <date> • <author> • <<sha>>", -- template for the blame message, check the Message template section for more options
			date_format = "%m-%d-%Y %H:%M:%S", -- template for the date, check Date format section for more options
			virtual_text_column = 1, -- virtual text start column, check Start virtual text at column section for more options
		},
	},
	{
		"folke/trouble.nvim",
		opts = {
			modes = {
				lsp = {
					win = { position = "right" },
				},
			},
			keys = {
				-- If I close the incorrect pane, I can bring it up with ctrl+o
				["<esc>"] = "close",
			},
		},
	},
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
				-- 基础行为设置
				-- stylua: ignore
				close_command = function(n) Snacks.bufdelete(n) end,
				-- stylua: ignore
				right_mouse_command = function(n) Snacks.bufdelete(n) end,
				separator_style = "slant",
				indicator = {
					style = "underline",
				},
				buffer_close_icon = "󰅖",
				modified_icon = "● ",
				close_icon = " ",
				left_trunc_marker = " ",
				right_trunc_marker = " ",

				diagnostics = "nvim_lsp",
				vim.diagnostic.config({ update_in_insert = true }),
				diagnostics_indicator = function(count, level)
					local icon = level:match("error") and " " or " "
					return " " .. icon .. count
				end,
				numbers = function(opts)
					return string.format(" %s/%s", vim.fn["tabpagenr"](), opts.ordinal)
				end,

				hover = {
					enabled = true,
					delay = 200,
					reveal = { "close" },
				},
				pick = {
					alphabet = "abcdefghijklmopqrstuvwxyzABCDEFGHIJKLMOPQRSTUVWXYZ1234567890",
				},

				-- 界面布局优化
				max_name_length = 18, -- 文件名最大显示长度
				tab_size = 18, -- 标签页宽度
				offsets = {
					{
						filetype = "NvimTree",
						text = "Explorer",
						highlight = "Directory",
						text_align = "left", -- 为 NvimTree 侧边栏预留空间[1](@ref)
					},
				},
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},
	{
		"tiagovla/scope.nvim",
		init = function()
			require("scope").setup({})
		end,
		keys = {
			{ "<M-n>", "<CMD>tabnext<CR>" },
			{ "<M-p>", "<CMD>tabprevious<CR>" },
		},
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
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
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
			},
			require("noice").setup({
				views = {
					-- 命令栏基础定位
					cmdline = {
						position = {
							row = "50%", -- 垂直居中
							col = "50%", -- 水平居中
						},
						size = {
							width = 60, -- 宽度占比
							height = "auto", -- 高度自适应
						},
					},
					-- 弹出式命令栏（类似 telescope）
					cmdline_popup = {
						position = {
							row = "50%", -- 贴近底部
							col = "50%",
						},
						border = {
							style = "rounded", -- 圆角边框
							padding = { 0, 1 },
						},
					},
				},
			}),
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		},
	},
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},
}
