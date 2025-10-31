-- lua/plugins/coc.lua
-- COC.nvim 配置 - 增强版本
return {
	{
		"neoclide/coc.nvim",
		branch = "release",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local diagnostics_utils = require("utils.diagnostics")
			local ensure_result = diagnostics_utils.ensure()
			local severity = (ensure_result.module and ensure_result.module.severity)
				or diagnostics_utils.get_severity_map()
			if not severity then
				severity = {
					ERROR = 1,
					WARN = 2,
					INFO = 3,
					HINT = 4,
				}
			end

			local VIM_NIL = rawget(vim, "NIL")

			local severity_lookup = {
				Error = severity.ERROR,
				Warning = severity.WARN,
				Information = severity.INFO,
				Hint = severity.HINT,
				ERROR = severity.ERROR,
				WARN = severity.WARN,
				INFO = severity.INFO,
				HINT = severity.HINT,
			}

			local diagnostic_namespace = vim.api.nvim_create_namespace("coc2nvim")
			local pending_request = false
			local request_again = false
			local last_error_message = nil

			local function normalize_number(value, default)
				if type(value) ~= "number" then
					return default
				end
				if value ~= value then
					return default
				end
				return value
			end

			local function resolve_position(entry)
				local start_line = entry.lnum or (entry.range and entry.range.start and entry.range.start.line + 1)
				local start_col = entry.col or (entry.range and entry.range.start and entry.range.start.character + 1)
				local end_line = entry.end_lnum
				if not end_line and entry.range and entry.range["end"] then
					end_line = entry.range["end"].line + 1
				end
				local end_col = entry.end_col
				if not end_col and entry.range and entry.range["end"] then
					end_col = entry.range["end"].character + 1
				end

				local lnum = math.max(0, normalize_number(start_line, 1) - 1)
				local col = math.max(0, normalize_number(start_col, 1) - 1)
				local final_end_line = normalize_number(end_line, start_line or (lnum + 1))
				local final_end_col = normalize_number(end_col, start_col or (col + 1))

				return lnum, col, math.max(lnum, final_end_line - 1), math.max(col, final_end_col - 1)
			end

			local function resolve_bufnr(entry, fallback)
				if entry.bufnr and vim.api.nvim_buf_is_valid(entry.bufnr) then
					return entry.bufnr
				end
				if entry.buffer and vim.api.nvim_buf_is_valid(entry.buffer) then
					return entry.buffer
				end
				if entry.file then
					local candidate = vim.fn.bufnr(entry.file)
					if candidate ~= -1 and vim.api.nvim_buf_is_valid(candidate) then
						return candidate
					end
				end
				if fallback and vim.api.nvim_buf_is_valid(fallback) then
					return fallback
				end
				return nil
			end

			local function apply_diagnostics(per_buffer)
				if not (vim.diagnostic and vim.diagnostic.set) then
					return
				end

				for target_bufnr, entries in pairs(per_buffer) do
					if vim.api.nvim_buf_is_valid(target_bufnr) then
						local converted = {}
						for _, entry in ipairs(entries) do
							local lnum, col, end_lnum, end_col = resolve_position(entry)
							table.insert(converted, {
								lnum = lnum,
								col = col,
								end_lnum = end_lnum,
								end_col = end_col,
								severity = severity_lookup[entry.severity] or severity.INFO,
								message = entry.message or "",
								source = entry.source or entry.server or "coc.nvim",
								code = entry.code,
							})
						end
						vim.diagnostic.set(diagnostic_namespace, target_bufnr, converted, {})
					end
				end

				last_error_message = nil
			end

			local function notify_once(message)
				if not message or message == "" then
					return
				end
				if last_error_message == message then
					return
				end
				last_error_message = message
				if vim.schedule then
					vim.schedule(function()
						vim.notify(message, vim.log.levels.WARN)
					end)
				else
					vim.notify(message, vim.log.levels.WARN)
				end
			end

			local function schedule_sync(bufnr_hint)
				if type(vim.fn.CocActionAsync) ~= "function" then
					return
				end

				local function request()
					pending_request = true
					local ok = pcall(vim.fn.CocActionAsync, "diagnosticList", function(err, result)
						pending_request = false
						if request_again then
							request_again = false
							schedule_sync(bufnr_hint)
						end

						if err and err ~= VIM_NIL and err ~= 0 then
							if type(err) == "string" and err ~= "" then
								notify_once("[coc.nvim] diagnostic sync failed: " .. err)
							end
							return
						end

						if type(result) ~= "table" then
							return
						end

						local fallback_bufnr = bufnr_hint and vim.api.nvim_buf_is_valid(bufnr_hint) and bufnr_hint
						local per_buffer = {}
						for _, entry in ipairs(result) do
							local target = resolve_bufnr(entry, fallback_bufnr)
							if target then
								per_buffer[target] = per_buffer[target] or {}
								table.insert(per_buffer[target], entry)
							end
						end

						if vim.schedule then
							vim.schedule(function()
								apply_diagnostics(per_buffer)
							end)
						else
							apply_diagnostics(per_buffer)
						end
					end)

					if not ok then
						pending_request = false
						notify_once("[coc.nvim] diagnostic request failed to start")
					end
				end

				if pending_request then
					request_again = true
					return
				end

				if vim.schedule then
					vim.schedule(request)
				else
					request()
				end
			end

			vim.api.nvim_create_autocmd("User", {
				pattern = "CocDiagnosticChange",
				callback = function(args)
					schedule_sync(args.buf or vim.api.nvim_get_current_buf())
				end,
				desc = "Bridge coc.nvim diagnostics to vim.diagnostic",
			})

			vim.api.nvim_create_autocmd("BufDelete", {
				callback = function(args)
					if vim.diagnostic and vim.diagnostic.reset then
						vim.diagnostic.reset(diagnostic_namespace, args.buf)
					end
				end,
			})

			schedule_sync()
			-- 核心扩展列表 (自动安装)
			vim.g.coc_global_extensions = {
				-- 核心语言支持
				"coc-json", -- JSON 支持
				"coc-html", -- HTML 支持
				"coc-css", -- CSS 支持
				"coc-yaml", -- YAML 支持
				"coc-pairs", -- 自动括号配对

				-- JavaScript/TypeScript 生态
				"coc-tsserver", -- TypeScript 语言服务器
				"coc-eslint", -- ESLint 集成
				"coc-prettier", -- Prettier 格式化

				-- Python 开发
				"coc-pyright", -- Python 语言服务器

				-- Web 开发增强
				"coc-emmet",     -- Emmet 支持
				"coc-stylelintplus", -- CSS/SCSS Lint

				-- 开发工具
				"coc-git",     -- Git 集成
				"coc-snippets", -- 代码片段
				"coc-lists",   -- 增强列表
				"coc-marketplace", -- 扩展市场

				-- AI 工具
				"coc-copilot", -- GitHub Copilot
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
