-- 搜索和补全增强插件配置
-- 文件路径: c:\Users\guoji\AppData\Local\nvim\lua\plugins\search.lua

return {
	-- 增强搜索功能
	{
		"nvim-pack/nvim-spectre",
		event = "VeryLazy",
		config = function()
			require("spectre").setup({
				color_devicons = true,
				highlight = {
					ui = "String",
					search = "DiffChange",
					replace = "DiffDelete",
				},
				mapping = {
					["toggle_line"] = {
						map = "dd",
						cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
						desc = "切换当前行",
					},
					["enter_file"] = {
						map = "<cr>",
						cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
						desc = "进入文件",
					},
					["send_to_qf"] = {
						map = "<leader>q",
						cmd = "<cmd>lua require('spectre.actions').send_to_qf()<CR>",
						desc = "发送所有项目到快速修复列表",
					},
					["replace_cmd"] = {
						map = "<leader>c",
						cmd = "<cmd>lua require('spectre.actions').replace_cmd()<CR>",
						desc = "输入替换命令",
					},
					["show_option_menu"] = {
						map = "<leader>o",
						cmd = "<cmd>lua require('spectre').show_options()<CR>",
						desc = "显示选项",
					},
					["run_current_replace"] = {
						map = "<leader>rc",
						cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
						desc = "替换当前行",
					},
					["run_replace"] = {
						map = "<leader>R",
						cmd = "<cmd>lua require('spectre.actions').run_replace()<CR>",
						desc = "替换所有",
					},
					["change_view_mode"] = {
						map = "<leader>v",
						cmd = "<cmd>lua require('spectre').change_view()<CR>",
						desc = "更改结果视图模式",
					},
					["resume_last_search"] = {
						map = "<leader>l",
						cmd = "<cmd>lua require('spectre').resume_last_search()<CR>",
						desc = "恢复上次搜索",
					},
				},
			})

			-- 键位映射
			vim.keymap.set("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', { desc = "切换 Spectre" })
			vim.keymap.set("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', { desc = "搜索当前单词" })
			vim.keymap.set("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', { desc = "搜索当前选择" })
			vim.keymap.set("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', { desc = "在当前文件搜索当前单词" })
		end,
	},

	-- 搜索时的单词补全 - 仅支持搜索模式 (/, ?)
	{
		"hrsh7th/cmp-cmdline",
		event = "CmdlineEnter",
		dependencies = { "hrsh7th/nvim-cmp", "hrsh7th/cmp-buffer" },
		config = function()
			local cmp = require("cmp")

			-- 只为搜索模式 (/, ?) 设置补全，提供缓冲区单词补全
			cmp.setup.cmdline({ "/", "?" }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})
		end,
	},

	-- FZF 搜索增强
	{
		"ibhagwan/fzf-lua",
		event = "VeryLazy",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("fzf-lua").setup({
				"telescope",
				winopts = {
					height = 0.85,
					width = 0.80,
					row = 0.35,
					col = 0.55,
					border = "rounded",
					preview = {
						vertical = "down:45%",
						horizontal = "right:50%",
						layout = "flex",
						flip_columns = 120,
					},
				},
				fzf_opts = {
					["--layout"] = "reverse-list",
				},
			})

			-- 键位映射
			vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "查找文件" })
			vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "实时搜索" })
			vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "查找缓冲区" })
			vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua help_tags<cr>", { desc = "帮助标签" })
			vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua oldfiles<cr>", { desc = "最近文件" })
			vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua commands<cr>", { desc = "命令" })
			vim.keymap.set("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", { desc = "键位映射" })
			vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", { desc = "文档符号" })
			vim.keymap.set("n", "<leader>fw", "<cmd>FzfLua grep_cword<cr>", { desc = "搜索当前单词" })
			vim.keymap.set("v", "<leader>fw", "<cmd>FzfLua grep_visual<cr>", { desc = "搜索选中文本" })
		end,
	},
}