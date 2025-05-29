return {
	-- 数据库查询工具
	{
		"tpope/vim-dadbod",
		dependencies = {
			"kristijanhusak/vim-dadbod-ui",
			"kristijanhusak/vim-dadbod-completion",
		},
		config = function()
			-- 设置数据库 UI 的全局变量
			vim.g.db_ui_use_nerd_fonts = 1
			vim.g.db_ui_show_database_icon = 1
			vim.g.db_ui_force_echo_notifications = 1
			vim.g.db_ui_win_position = "left"
			vim.g.db_ui_winwidth = 30
			
			-- 默认数据库配置示例 (可根据需要修改)
			vim.g.dbs = {
				-- sqlite_local = 'sqlite:' .. vim.fn.expand('~/local.db'),
				-- mysql_local = 'mysql://user:password@localhost:3306/database',
				-- postgresql_local = 'postgresql://user:password@localhost:5432/database',
			}

			-- 自动命令：在 sql 文件中启用数据库补全
			vim.api.nvim_create_autocmd("FileType", {
				pattern = { "sql", "mysql", "plsql" },
				callback = function()
					require("cmp").setup.buffer({
						sources = {
							{ name = "vim-dadbod-completion" },
							{ name = "buffer" },
						},
					})
				end,
			})
			
			-- 键位映射
			vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<cr>", { desc = "切换数据库UI" })
			vim.keymap.set("n", "<leader>df", "<cmd>DBUIFindBuffer<cr>", { desc = "查找数据库缓冲区" })
			vim.keymap.set("n", "<leader>dr", "<cmd>DBUIRenameBuffer<cr>", { desc = "重命名数据库缓冲区" })
			vim.keymap.set("n", "<leader>dq", "<cmd>DBUILastQueryInfo<cr>", { desc = "显示最后查询信息" })
		end,
	},
	-- 高级数据库工具 (可选)
	{
		"kndndrj/nvim-dbee",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		build = function()
			require("dbee").install()
		end,
		config = function()
			require("dbee").setup({
				-- 数据库连接配置
				sources = {
					require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
					require("dbee.sources").FileSource:new(vim.fn.stdpath("config") .. "\\dbee\\connections.json"),
				},
			})
			
			-- 键位映射
			vim.keymap.set("n", "<leader>do", function()
				require("dbee").open()
			end, { desc = "打开 Dbee" })
			
			vim.keymap.set("n", "<leader>dc", function()
				require("dbee").close()
			end, { desc = "关闭 Dbee" })
		end,
	},
}
