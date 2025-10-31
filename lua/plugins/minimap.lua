return {
	"echasnovski/mini.map",
	version = false,
	event = "VeryLazy",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"lewis6991/gitsigns.nvim",
	},
	config = function()
		local map = require("mini.map")
		local ts_bridge = nil
		pcall(function()
			ts_bridge = require("utils.treesitter")
		end)

		-- 高亮渲染器
		local symbols = map.gen_encode_symbols.dot("4x2")

		-- 高亮集成模块
		local diagnostic_integration = map.gen_integration.diagnostic({
			error = "DiagnosticFloatingError",
			warn = "DiagnosticFloatingWarn",
			info = "DiagnosticFloatingInfo",
			hint = "DiagnosticFloatingHint",
		})

		local integrations = {
			map.gen_integration.builtin_search(), -- 搜索结果 (/ 或 ?)
			map.gen_integration.gitsigns(),        -- Git 变更标记
			diagnostic_integration,                -- LSP 诊断标记（全部级别）
		}

		local ts_integration = ts_bridge and ts_bridge.minimap_integration and ts_bridge.minimap_integration(map)
		if ts_integration then
			table.insert(integrations, 1, ts_integration)
		end

		-- 配置主体
		map.setup({
			integrations = integrations,
			symbols = symbols,
			window = {
				side = "right",
				width = 10,
				winblend = 25,
				show_integration_count = false,
			},
		})

		-- 启动时打开 minimap（排除特定类型）
		vim.api.nvim_create_autocmd("BufEnter", {
			callback = function()
				local ignore_ft = { "NvimTree", "TelescopePrompt", "help", "dashboard" }
				if not vim.tbl_contains(ignore_ft, vim.bo.filetype) then
					map.open()
				end
			end,
		})

		-- 快捷键
		vim.keymap.set("n", "<leader>mm", map.toggle, { desc = "Toggle mini.map" })
		vim.keymap.set("n", "<leader>mr", map.refresh, { desc = "Refresh mini.map" })
		vim.keymap.set("n", "<leader>mf", map.toggle_focus, { desc = "Toggle mini.map focus" })
	end,
}
