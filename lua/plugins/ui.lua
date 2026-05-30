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

-- 选择计数显示（简化版，使用 Vim 内置功能）
local function selectionCount()
	local mode = vim.fn.mode()
	if not (mode == "v" or mode == "V" or mode == "\22") then
		return ""
	end

	-- 使用 Vim 内置的选择信息
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")

	if mode == "V" then
		-- 行选择模式
		local lines = math.abs(end_pos[2] - start_pos[2]) + 1
		return string.format("📝%d lines", lines)
	elseif mode == "\22" then
		-- 块选择模式
		local lines = math.abs(end_pos[2] - start_pos[2]) + 1
		local cols = math.abs(end_pos[3] - start_pos[3]) + 1
		return string.format("⬛%dx%d", lines, cols)
	else
		-- 字符选择模式 - 使用简单的字符计数
		local text = get_visual_selection()
		local chars = vim.fn.strchars(text)
		local bytes = vim.fn.strlen(text)

		-- 如果字符数和字节数不同，说明有多字节字符（如中文）
		if chars ~= bytes then
			return string.format("�%d chars (%d bytes)", chars, bytes)
		else
			return string.format("�%d chars", chars)
		end
	end
end

local char_count_cache = {}

local function next_utf8_codepoint(text, index)
	local first = text:byte(index)
	if not first then
		return nil, index
	end

	if first < 0x80 then
		return first, index + 1
	end

	local second = text:byte(index + 1)
	if first < 0xE0 and second then
		return ((first % 0x20) * 0x40) + (second % 0x40), index + 2
	end

	local third = text:byte(index + 2)
	if first < 0xF0 and second and third then
		return ((first % 0x10) * 0x1000) + ((second % 0x40) * 0x40) + (third % 0x40), index + 3
	end

	local fourth = text:byte(index + 3)
	if first < 0xF8 and second and third and fourth then
		return ((first % 0x08) * 0x40000) + ((second % 0x40) * 0x1000) + ((third % 0x40) * 0x40) + (fourth % 0x40),
			index + 4
	end

	return first, index + 1
end

local function count_eng_zh_chars(text)
	local eng_count, zh_count, digit_count, total_chars = 0, 0, 0, 0

	local index = 1
	while index <= #text do
		local code
		code, index = next_utf8_codepoint(text, index)
		total_chars = total_chars + 1
		if (code >= 65 and code <= 90) or (code >= 97 and code <= 122) then
			eng_count = eng_count + 1
		elseif code >= 48 and code <= 57 then
			digit_count = digit_count + 1
		elseif
			(code >= 0x4E00 and code <= 0x9FFF)
			or (code >= 0x3400 and code <= 0x4DBF)
			or (code >= 0x20000 and code <= 0x2A6DF)
		then
			zh_count = zh_count + 1
		end
	end

	return eng_count, zh_count, digit_count, total_chars
end

local function format_char_stats(eng_count, zh_count, digit_count, total_chars)
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

local function update_char_count_cache(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
	local cache = char_count_cache[bufnr] or {}

	if line_count > 5000 then
		cache.changedtick = changedtick
		cache.display = string.format("󰈙 %dL", line_count)
		cache.pending = false
		char_count_cache[bufnr] = cache
		return
	end

	local content = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	cache.changedtick = changedtick
	cache.display = format_char_stats(count_eng_zh_chars(content))
	cache.pending = false
	char_count_cache[bufnr] = cache
end

local function schedule_char_count_update(bufnr)
	local cache = char_count_cache[bufnr] or {}
	if cache.pending then
		return
	end

	cache.pending = true
	char_count_cache[bufnr] = cache

	vim.defer_fn(function()
		update_char_count_cache(bufnr)
		pcall(vim.cmd.redrawstatus)
	end, 350)
end

local function cachedCharCount()
	local bufnr = vim.api.nvim_get_current_buf()
	local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
	local cache = char_count_cache[bufnr]

	if cache and cache.changedtick == changedtick and cache.display then
		return cache.display
	end

	schedule_char_count_update(bufnr)
	return cache and cache.display or string.format("󰈙 %dL", vim.api.nvim_buf_line_count(bufnr))
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
								end

								return cachedCharCount()
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
			vim.api.nvim_create_autocmd("BufWipeout", {
				callback = function(args)
					char_count_cache[args.buf] = nil
				end,
			})
		end,
	},

	-- 文件树
	{
		"nvim-tree/nvim-tree.lua",
		enabled = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		lazy = false, -- 🌟 确保它在输入 nvim . 时立刻启动
		init = function()
			-- 🌟 必须在 init 中（插件加载前）禁用系统自带的 netrw
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1
		end,
		keys = { { "<leader>e", "<CMD>NvimTreeToggle<CR>" } },
		config = function()
			local function my_on_attach(bufnr)
				local api = require("nvim-tree.api")
				local function opts(desc)
					return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
				end

				api.config.mappings.default_on_attach(bufnr)

				vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
				vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))
				vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
				vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
				vim.keymap.set("n", "o", api.node.open.vertical, opts("Open: Vertical Split"))
			end

			require("nvim-tree").setup({
				sync_root_with_cwd = true,
				respect_buf_cwd = true,
				-- 🌟 无视代码补全的警告，强行加入接管目录的配置
				hijack_directories = {
					enable = true,
					auto_open = true,
				},
				sort_by = "case_sensitive",
				hijack_cursor = true,
				system_open = { cmd = "open" },
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
				git = { enable = true, ignore = false },
				update_focused_file = { enable = true, update_root = true },
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
			local function open_nvim_tree(data)
				-- 1. 判断传入的是否为真实文件夹
				local directory = vim.fn.isdirectory(data.file) == 1
				if not directory then
					return
				end

				-- 🌟 关键 1：在主窗口新建一个干净的空 Buffer
				vim.cmd.enew()

				-- 🌟 关键 2：把原本那个“坏掉的/僵尸”文件夹 Buffer 彻底抹除 (wipeout)
				vim.cmd.bw(data.buf)

				-- 3. 将 Neovim 的工作目录切换到该文件夹
				vim.cmd.cd(data.file)

				-- 4. 强制调用 nvim-tree API 打开并渲染
				require("nvim-tree.api").tree.open()
			end -- 绑定在 VimEnter 事件上，确保在所有插件加载完后执行
			vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
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
					{
						filetype = "snacks_picker_input",
						text = "Explorer",
						highlight = "Directory",
						text_align = "left",
					},
					{
						filetype = "snacks_picker_list",
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
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
				signature = {
					enabled = true,
					auto_open = {
						enabled = true,
						trigger = true,
						luasnip = true,
						throttle = 50,
					},
					view = "hover",
					opts = {},
				},
				hover = {
					enabled = true,
					view = nil,
					opts = {},
				},
			},
			-- [优化重点 1]: 路由规则配置
			routes = {
				-- 1. 消除噪音：过滤掉 "Search hit BOTTOM" 这类在使用居中弹窗时非常烦人的提示
				{
					filter = {
						event = "msg_show",
						kind = "search_count",
					},
					opts = { skip = true },
				},
				{
					filter = {
						event = "msg_show",
						find = "lines? --%d+%%--", -- 过滤翻页百分比提示
					},
					opts = { skip = true },
				},
				-- 2. 优化文件保存提示：将 "written" 消息精简到 mini 视图，防止占据屏幕
				{
					filter = {
						event = "msg_show",
						kind = "",
						find = "written",
					},
					view = "mini",
				},
				-- 交互确认必须走小确认框，避免被下面的多行 popup 规则放大。
				{
					filter = {
						event = "msg_show",
						any = {
							{ kind = "confirm" },
							{ kind = "confirm_sub" },
							{ kind = "number_prompt" },
						},
					},
					view = "confirm",
				},
				-- 3. [核心修复]: 强制显示外部命令 (:!) 输出
				-- 如果输出包含换行符，或者不是简单的单行提示，强制使用 popup 显示
				-- 防止被 messages.view = "mini" 吞掉
				{
					filter = {
						event = "msg_show",
						min_height = 2, -- 如果消息超过2行
					},
					view = "popup", -- 强制弹窗显示
				},
				-- 之前的规则：过滤光标位置信息等
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
			},
			presets = {
				bottom_search = false,
				command_palette = true,
				long_message_to_split = true, -- 关键：长消息自动分屏
				lsp_doc_border = true, -- 建议开启：让 LSP 文档也就是 hover 有边框
			},
			cmdline = {
				enabled = true,
				view = "cmdline_popup",
				opts = {},
				format = {
					cmdline = { pattern = "^:", lang = "vim" },
					search_down = { kind = "search", pattern = "^/", lang = "regex" },
					search_up = { kind = "search", pattern = "^%?", lang = "regex" },
					filter = { pattern = "^:%s*!", lang = "bash", view = "cmdline_popup" },
					lua = { pattern = "^:%s*lua%s+", lang = "lua" },
					help = { pattern = "^:%s*he?l?p?%s+" },
					input = {},
				},
			},
			messages = {
				enabled = true,
				-- [注意] 这里保留了你的设置，但上面的 routes 会拦截重要消息去 popup
				view = "mini",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = "virtualtext",
			},
			popupmenu = {
				enabled = true,
				backend = "nui",
				kind_icons = {},
			},
			-- 布局保持原样
			views = {
				cmdline_popup = {
					position = { row = "50%", col = "50%" },
					size = { width = 60, height = "auto" },
					border = { style = "rounded", padding = { 0, 1 } },
					filter_options = {},
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 10,
					},
				},
				popupmenu = {
					relative = "editor",
					position = { row = "70%", col = "50%" },
					size = { width = 60, height = 15 },
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 10,
					},
				},
				hover = {
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 10,
					},
				},
				confirm = {
					backend = "popup",
					relative = "editor",
					focusable = false,
					align = "left",
					enter = false,
					zindex = 210,
					format = { "{confirm}" },
					position = { row = "50%", col = "50%" },
					size = { width = 52, height = "auto" },
					border = { style = "single", padding = { 0, 1 } },
					win_options = {
						winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder",
						winblend = 0,
						winbar = "",
						foldenable = false,
					},
				},
				-- [新增] 针对上面定义的 "popup" 视图的默认样式，确保 :! 输出好看
				popup = {
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = "NormalFloat:NormalFloat,FloatBorder:FloatBorder",
						winblend = 0, -- 重要消息不透明，防止看不清
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
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
				[".gitignore"] = { glyph = "", hl = "MiniIconsOrange" },
				[".env"] = { glyph = "", hl = "MiniIconsYellow" },
				["README.md"] = { glyph = "󰂺", hl = "MiniIconsBlue" },
				["package.json"] = { glyph = "", hl = "MiniIconsGreen" },
				["tsconfig.json"] = { glyph = "", hl = "MiniIconsBlue" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
				git = { glyph = "", hl = "MiniIconsOrange" },
				lua = { glyph = "", hl = "MiniIconsBlue" },
				python = { glyph = "", hl = "MiniIconsYellow" },
				javascript = { glyph = "", hl = "MiniIconsYellow" },
				typescript = { glyph = "", hl = "MiniIconsBlue" },
				rust = { glyph = "", hl = "MiniIconsRed" },
				go = { glyph = "", hl = "MiniIconsCyan" },
				json = { glyph = "", hl = "MiniIconsYellow" },
				yaml = { glyph = "", hl = "MiniIconsRed" },
				markdown = { glyph = "", hl = "MiniIconsBlue" },
			},
			directory = {
				[".git"] = { glyph = "", hl = "MiniIconsOrange" },
				[".github"] = { glyph = "", hl = "MiniIconsGrey" },
				["node_modules"] = { glyph = "", hl = "MiniIconsGreen" },
				["src"] = { glyph = "󰉋", hl = "MiniIconsBlue" },
				["lib"] = { glyph = "󰲂", hl = "MiniIconsPurple" },
				["config"] = { glyph = "", hl = "MiniIconsYellow" },
				["docs"] = { glyph = "󰈙", hl = "MiniIconsBlue" },
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
