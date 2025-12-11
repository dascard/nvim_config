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

		local function ensure_minimap_highlight(target, fallback, defaults)
			local opts = { default = true }
			local ok, base = pcall(vim.api.nvim_get_hl, 0, { name = fallback, link = false })
			if ok and base then
				if base.bg then
					opts.bg = base.bg
				end
				if base.fg then
					opts.fg = base.fg
					if not opts.bg then
						opts.bg = base.fg
					end
				end
			end
			if not opts.bg then
				opts.bg = defaults.bg
			end
			if not opts.fg then
				opts.fg = defaults.fg or opts.bg
			end
			vim.api.nvim_set_hl(0, target, opts)
		end

		local diagnostic_highlights = {
			error = "MiniMapDiagnosticError",
			warn = "MiniMapDiagnosticWarn",
			info = "MiniMapDiagnosticInfo",
			hint = "MiniMapDiagnosticHint",
		}

		local highlight_defaults = {
			error = { fallback = "DiagnosticVirtualTextError", bg = "#F44747", fg = "#1F1F1F" },
			warn = { fallback = "DiagnosticVirtualTextWarn", bg = "#FFB74C", fg = "#1F1F1F" },
			info = { fallback = "DiagnosticVirtualTextInfo", bg = "#61AFEF", fg = "#1F1F1F" },
			hint = { fallback = "DiagnosticVirtualTextHint", bg = "#98C379", fg = "#1F1F1F" },
		}

		for severity, group in pairs(diagnostic_highlights) do
			local defaults = highlight_defaults[severity]
			if defaults then
				ensure_minimap_highlight(group, defaults.fallback, defaults)
			end
		end

		-- 高亮集成模块
		local diagnostic_integration = map.gen_integration.diagnostic(diagnostic_highlights)

		local integrations = {
			diagnostic_integration,            -- LSP 诊断标记优先显示
			map.gen_integration.builtin_search(), -- 搜索结果 (/ 或 ?)
			map.gen_integration.gitsigns(),    -- Git 变更标记
		}

		local ts_integration = ts_bridge and ts_bridge.minimap_integration and ts_bridge.minimap_integration(map)
		if ts_integration then
			table.insert(integrations, ts_integration)
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
			group = vim.api.nvim_create_augroup("KeepFeatureClosedInSpecialBuffers", { clear = true }),
			callback = function()
				-- 1. 定义一个不应触发功能的“黑名单”文件类型
				local ignored_filetypes = {
					"NvimTree",
					"TelescopePrompt",
					"help",
					"dashboard",
					"lazy",
					"mason",
					"sidekick_terminal",
					"qf", -- Quickfix 列表
					"Avante",
					"AvanteSelectedFiles",
					"AvanteInput",
				}

				-- 2. 检查当前文件类型是否在黑名单中
				if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
					-- 如果是，则执行“关闭”操作
					-- 请将下面的示例命令替换成你自己的
					-- vim.cmd('YourPluginCloseCommand')
					map.close()
				else
					-- 否则（对于普通文件），执行“打开”操作
					-- 请将下面的示例命令替换成你自己的
					-- vim.cmd('YourPluginOpenCommand')
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
