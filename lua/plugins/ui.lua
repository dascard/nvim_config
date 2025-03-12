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
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
				},
				sections = { lualine_c = { { "filename", path = 1 } } },
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
