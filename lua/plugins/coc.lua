-- lua/plugins/coc.lua
-- COC.nvim 配置 - 简洁稳定版本
return {
	{
		"neoclide/coc.nvim",
		branch = "release",
		event = { "BufReadPre", "BufNewFile" },
		Lazy = true,
		event = VeryLazy,
		config = function()
			-- Windows 兼容的基础扩展列表
			vim.g.coc_global_extensions = {
				"coc-json",      -- JSON
				"coc-html",      -- HTML
				"coc-css",       -- CSS
				"coc-yaml",      -- YAML
				"coc-pairs",     -- 自动括号
				-- 格式化工具
				"coc-prettier",  -- 前端代码格式化
				"coc-eslint",    -- JavaScript/TypeScript 检查
				"coc-stylelintplus", -- CSS/SCSS 格式化
				"coc-markdownlint", -- Markdown 格式化
				-- "coc-sql",                   -- SQL 格式化

				-- AI 和增强功能
				"coc-lists", -- 列表增强
				"coc-explorer", -- 文件浏览器
				"coc-git",   -- Git 集成
				"coc-highlight", -- 语法高亮增强

				-- 文档和工具
				"coc-spell-checker", -- 拼写检查
				"coc-translator", -- 翻译工具
				"coc-marketplace", -- 扩展市场			"co                "coc-snippets",              -- 代码片段引擎

				-- Snippet 扩展
				"coc-ultisnips", -- UltiSnips 支持
				"coc-neosnippet", -- NeoSnippet 支持
				"coc-emoji",  -- Emoji 支持
				"coc-dictionary", -- 字典补全
				"coc-syntax", -- 语法增强
			}
			-- 基本设置
			local node_path = "node"
			if vim.fn.has("win32") == 1 then
				-- Windows 上尝试找到 Node.js
				local possible_paths = { "node", "node.exe" }
				for _, path in ipairs(possible_paths) do
					if vim.fn.executable(path) == 1 then
						node_path = path
						break
					end
				end
			end
			vim.g.coc_node_path = node_path

			vim.opt.backup = false
			vim.opt.writebackup = false
			vim.opt.updatetime = 300
			vim.opt.signcolumn = "yes"

			local keyset = vim.keymap.set

			-- Tab 补全函数
			function _G.check_back_space()
				local col = vim.fn.col('.') - 1
				return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
			end

			-- 补全和导航键映射
			local opts = { silent = true, noremap = true, expr = true, replace_keycodes = false }
			-- Tab 键 - 选择下一个补全项或缩进
			keyset("i", "<down>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<down>" : coc#refresh()',
				opts)
			keyset("i", "<up>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<up>"]], opts)

			-- Enter 键 - 确认补全或换行（官方推荐配置）
			-- keyset("i", "<Tab>", [[coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() : "\<C-g>u\<cr>\<c-r>=coc#on_enter()\<TAB>"]], {silent = true, noremap = true, expr = true, replace_keycodes = true, unique = true})
			keyset("i", "<Tab>", [[coc#pum#visible() && coc#pum#info()['index'] != -1 ? coc#pum#confirm() : "\<TAB>"]], opts)

			-- Snippet 和补全触发
			keyset("i", "<c-j>", "<Plug>(coc-snippets-expand-jump)")
			keyset("i", "<c-space>", "coc#refresh()", { silent = true, expr = true })

			-- 诊断导航
			keyset("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
			keyset("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

			-- 代码导航
			keyset("n", "gd", "<Plug>(coc-definition)", { silent = true })
			keyset("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
			keyset("n", "gi", "<Plug>(coc-implementation)", { silent = true })
			keyset("n", "gr", "<Plug>(coc-references)", { silent = true })

			-- 显示文档
			function _G.show_docs()
				local cw = vim.fn.expand('<cword>')
				if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
					vim.api.nvim_command('h ' .. cw)
				elseif vim.api.nvim_eval('coc#rpc#ready()') then
					vim.fn.CocActionAsync('doHover')
				else
					vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
				end
			end

			keyset("n", "K", '<CMD>lua _G.show_docs()<CR>', { silent = true })

			-- 重命名和代码操作
			keyset("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })
			keyset("n", "<leader>ac", "<Plug>(coc-codeaction-cursor)", { silent = true })
			keyset("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true })

			-- 格式化
			keyset("x", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })
			keyset("n", "<leader>f", "<Plug>(coc-format-selected)", { silent = true })

			-- 浮动窗口滚动
			local opts_scroll = { silent = true, nowait = true, expr = true }
			keyset("n", "<C-f>", 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts_scroll)
			keyset("n", "<C-b>", 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-b>"', opts_scroll)

			-- COC 列表
			local opts_list = { silent = true, nowait = true }
			keyset("n", "<space>a", ":<C-u>CocList diagnostics<cr>", opts_list)
			keyset("n", "<space>e", ":<C-u>CocList extensions<cr>", opts_list)
			keyset("n", "<space>c", ":<C-u>CocList commands<cr>", opts_list)
			keyset("n", "<space>o", ":<C-u>CocList outline<cr>", opts_list)
			keyset("n", "<space>s", ":<C-u>CocList -I symbols<cr>", opts_list)

			-- 用户命令
			vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})
			vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})

			-- 符号高亮
			vim.api.nvim_create_augroup("CocGroup", {})
			vim.api.nvim_create_autocmd("CursorHold", {
				group = "CocGroup",
				command = "silent call CocActionAsync('highlight')",
				desc = "Highlight symbol under cursor"
			})

			-- 状态行支持
			vim.opt.statusline:prepend("%{coc#status()}%{get(b:,'coc_current_function','')}")
		end,
	},
}
