vim.cmd("syntax on")
vim.cmd("filetype indent on")
vim.opt.backup = false
vim.opt.clipboard = "unnamedplus"
vim.opt.cmdheight = 2
vim.opt.completeopt = { "menuone", "noselect" }
vim.opt.conceallevel = 2
vim.opt.fileencoding = "utf-8"
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.mouse = "a"
-- vim.opt.pumheight = 20 -- Duplicate removed
vim.opt.foldmethod = "marker"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.laststatus = 3
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.termguicolors = true
vim.opt.timeoutlen = 500
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.writebackup = false
vim.opt.confirm = true

-- LSP 切换命令已移至 lua/lsp_switch.lua
-- 使用 :ToggleLSP 在 coc.nvim 和原生 LSP 之间切换
-- 使用 :LSPMode 查看当前模式
-- 使用 :UseCoc 或 :UseNativeLSP 直接切换到指定模式

-- 命令行补全设置（由 noice.nvim 接管）
vim.opt.wildmenu = true -- 启用命令行补全菜单
vim.opt.wildmode = "longest:full,full" -- 设置补全行为
-- 注释掉 wildoptions，让 noice.nvim 处理显示
-- vim.opt.wildoptions = "pum,fuzzy"  -- 使用popup菜单显示补全，支持模糊匹配
vim.opt.pumheight = 15 -- 设置补全菜单最大高度

-- 透明度配置 (降低透明度使浮动窗口背景更明显)
vim.opt.pumblend = 10 -- 补全菜单透明度 (降低以增加对比度)
vim.opt.winblend = 10 -- 浮动窗口透明度 (降低以增加对比度)

-- 设置 leader 键
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- lua tap=2
--vim.api.nvim_create_autocmd("FileType", {
--	pattern = {"lua", "cpp"}
--	callback = function()
--		vim.opt_local.shiftwidth = 2
--		vim.opt_local.tabstop = 2
--	end,
--})
-- ssh remote copy
if vim.env.SSH_CONNECTION and pcall(require, "vim.ui.clipboard.osc52") then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = require("vim.ui.clipboard.osc52").paste("+"),
			["*"] = require("vim.ui.clipboard.osc52").paste("*"),
		},
	}
end
-- user event that loads after UIEnter + only if file buf is there
vim.api.nvim_create_autocmd({ "UIEnter", "BufReadPost", "BufNewFile" }, {
	group = vim.api.nvim_create_augroup("UserFilePost", { clear = true }),
	callback = function(args)
		local file = vim.api.nvim_buf_get_name(args.buf)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })

		if not vim.g.ui_entered and args.event == "UIEnter" then
			vim.g.ui_entered = true
		end

		if file ~= "" and buftype ~= "nofile" and vim.g.ui_entered then
			vim.api.nvim_exec_autocmds("User", { pattern = "FilePost", modeline = false })
			vim.api.nvim_del_augroup_by_name("UserFilePost")
			vim.schedule(function()
				vim.api.nvim_exec_autocmds("FileType", {})
			end)
		end
	end,
})
-- go to last location when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = vim.api.nvim_create_augroup("UserLastLoc", { clear = true }),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].user_last_loc then
			return
		end
		vim.b[buf].user_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(buf) then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

vim.wo.winhighlight = "NormalFloat:Normal" -- 继承主题背景色

-- CMP 配置已禁用，现在使用 COC.nvim
-- require("cmp").setup({
-- 	window = {
-- 		completion = {
-- 			winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None",
-- 		},
-- 		documentation = {
-- 			winhighlight = "Normal:NormalFloat",
-- 		},
-- 	},
-- })

vim.diagnostic.config({
	float = {
		source = "always",
		header = { " Diagnostics:", "Normal" },
		prefix = function(diag)
			return " " .. diag.severity .. ": "
		end,
	},
})

-- 自定义诊断高亮
vim.api.nvim_set_hl(0, "DiagnosticFloatingError", { link = "LspDiagnosticsFloatingError" })

-- asyncrun.vim
vim.g.asyncrun_open = 10
vim.g.asyncrun_rootmarks = { ".git", ".svn", ".root", ".project", ".hg" }
vim.g.asyncrun_save = 2
vim.g.asynctasks_term_pos = "right"

-- Define the highlight group for border characters
-- -- 设置高亮组，兼容 GUI 和终端
-- vim.cmd("hi BorderChar guifg=#FF0000 ctermfg=Red gui=bold cterm=bold")
--
-- -- 存储 match ID
-- local match_id = nil
--
-- -- 高亮当前行的上下边框和边界
-- local function HighlightBorder()
-- 	-- 删除已有高亮
-- 	if match_id and match_id > 0 then
-- 		pcall(vim.fn.matchdelete, match_id)
-- 	end
--
-- 	-- 获取当前行号和总行数
-- 	local current_line = vim.fn.line(".")
-- 	local last_line = vim.fn.line("$")
--
-- 	if current_line <= 1 or current_line >= last_line then
-- 		return
-- 	end
--
-- 	-- 生成匹配模式：上一行、下一行、当前行的首尾字符
-- 	local pattern = string.format(
-- 		"\\%%%dl.*\\|\\%%%dl.*\\|\\%%%dl\\%%%dc\\|\\%%%dl\\%%%dc",
-- 		current_line - 1, -- 上一行
-- 		current_line + 1, -- 下一行
-- 		current_line,
-- 		1, -- 当前行第一个字符
-- 		current_line,
-- 		vim.fn.col("$") - 1 -- 当前行最后一个字符
-- 	)
--
-- 	-- 添加高亮
-- 	match_id = vim.fn.matchadd("BorderChar", pattern)
--
-- 	print("Highlight updated: ", match_id)
-- end
--
-- -- 设置自动命令
-- vim.api.nvim_create_augroup("HighlightBorderGroup", { clear = true })
-- vim.api.nvim_create_autocmd("CursorMoved", {
-- 	group = "HighlightBorderGroup",
-- 	callback = HighlightBorder,
-- })
--
-- print("Border Highlighter Loaded")

-- UI 浮动窗口对比度增强设置
-- 使用深色半透明背景使浮动窗口与代码区域更容易区分
vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "*",
	callback = function()
		-- 浮动窗口背景色 (深色半透明，增加对比度)
		local float_bg = "#1a1b26" -- tokyonight 深色背景
		local float_border_fg = "#7aa2f7" -- tokyonight 蓝色边框
		local pmenu_sel_bg = "#364a82" -- 选中项高亮背景

		-- 浮动窗口样式
		vim.api.nvim_set_hl(0, "NormalFloat", { bg = float_bg })
		vim.api.nvim_set_hl(0, "FloatBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#c0caf5", bg = float_bg, bold = true })

		-- 补全菜单样式 (Pmenu)
		vim.api.nvim_set_hl(0, "Pmenu", { fg = "#c0caf5", bg = float_bg })
		vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#c0caf5", bg = pmenu_sel_bg, bold = true })
		vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#292e42" })
		vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#7aa2f7" })
		vim.api.nvim_set_hl(0, "PmenuBorder", { fg = float_border_fg, bg = float_bg })

		-- COC 浮动窗口样式
		vim.api.nvim_set_hl(0, "CocFloating", { bg = float_bg })
		vim.api.nvim_set_hl(0, "CocPumMenu", { fg = "#c0caf5", bg = float_bg })
		vim.api.nvim_set_hl(0, "CocPumSearch", { fg = "#ff9e64", bg = float_bg, bold = true })
		vim.api.nvim_set_hl(0, "CocMenuSel", { fg = "#c0caf5", bg = pmenu_sel_bg, bold = true })
		vim.api.nvim_set_hl(0, "CocPumShortcut", { fg = "#565f89", bg = float_bg })
		vim.api.nvim_set_hl(0, "CocPumDeprecated", { fg = "#565f89", bg = float_bg, strikethrough = true })

		-- Telescope 样式
		vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = float_bg })
		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "#292e42" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = float_border_fg, bg = "#292e42" })
		vim.api.nvim_set_hl(0, "TelescopeSelection", { bg = pmenu_sel_bg })

		-- Noice 命令行和弹窗样式
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopup", { bg = float_bg })
		vim.api.nvim_set_hl(0, "NoiceCmdlinePopupBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "NoicePopupmenu", { bg = float_bg })
		vim.api.nvim_set_hl(0, "NoicePopupmenuBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "NoicePopupmenuSelected", { bg = pmenu_sel_bg })

		-- Snacks 通知和 picker 样式
		vim.api.nvim_set_hl(0, "SnacksInputNormal", { bg = float_bg })
		vim.api.nvim_set_hl(0, "SnacksInputBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "SnacksNotifierHistory", { bg = float_bg })

		-- blink.cmp 补全菜单样式
		vim.api.nvim_set_hl(0, "BlinkCmpMenu", { bg = float_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = float_border_fg, bg = float_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpMenuSelection", { bg = pmenu_sel_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpDoc", { bg = float_bg })
		vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = float_border_fg, bg = float_bg })

		-- Which-key 样式
		vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = float_bg })
		vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = float_border_fg, bg = float_bg })

		-- LSP 相关浮动窗口
		vim.api.nvim_set_hl(0, "LspInfoBorder", { fg = float_border_fg, bg = float_bg })

		-- 侧边栏保持透明
		vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "NONE" })
		vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "NONE" })
	end,
})

-- 设置全局浮动窗口默认配置
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
	winblend = 10, -- 降低透明度以增加对比度
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
	winblend = 10, -- 降低透明度以增加对比度
})

-- 终端复制模式：隐藏插件 UI，仅保留纯文本
local terminal_copy_state = nil
local terminal_copy_augroup = vim.api.nvim_create_augroup("TerminalCopyMode", { clear = true })

local function snapshot_window_opts(win)
	return {
		number = vim.wo[win].number,
		relativenumber = vim.wo[win].relativenumber,
		signcolumn = vim.wo[win].signcolumn,
		foldcolumn = vim.wo[win].foldcolumn,
		cursorline = vim.wo[win].cursorline,
		list = vim.wo[win].list,
		colorcolumn = vim.wo[win].colorcolumn,
		winbar = vim.wo[win].winbar,
		statuscolumn = vim.wo[win].statuscolumn,
	}
end

local function apply_terminal_copy_window(win)
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].foldcolumn = "0"
	vim.wo[win].cursorline = false
	vim.wo[win].list = false
	vim.wo[win].colorcolumn = ""
	vim.wo[win].winbar = ""
	vim.wo[win].statuscolumn = ""
end

local function enable_terminal_copy_mode()
	if terminal_copy_state then
		return
	end

	terminal_copy_state = {
		options = {
			laststatus = vim.o.laststatus,
			showtabline = vim.o.showtabline,
			cmdheight = vim.o.cmdheight,
			showmode = vim.o.showmode,
			ruler = vim.o.ruler,
			showcmd = vim.o.showcmd,
			conceallevel = vim.o.conceallevel,
			statusline = vim.o.statusline,
			winbar = vim.o.winbar,
		},
		default_window = snapshot_window_opts(0),
		windows = {},
		globals = {
			snacks_indent = vim.g.snacks_indent,
			snacks_scope = vim.g.snacks_scope,
			gitblame_enabled = vim.g.gitblame_enabled,
		},
		diagnostics_enabled = (vim.diagnostic.is_enabled and vim.diagnostic.is_enabled()) or nil,
		inlay_hint_enabled = nil,
		ibl_enabled = nil,
	}

	local ok_ibl_conf, ibl_conf = pcall(require, "ibl.config")
	if ok_ibl_conf and ibl_conf.get_config then
		terminal_copy_state.ibl_enabled = ibl_conf.get_config(0).enabled
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		terminal_copy_state.windows[win] = snapshot_window_opts(win)
		apply_terminal_copy_window(win)
	end

	vim.o.laststatus = 0
	vim.o.showtabline = 0
	vim.o.cmdheight = 0
	vim.o.showmode = false
	vim.o.ruler = false
	vim.o.showcmd = false
	vim.o.conceallevel = 0
	vim.o.statusline = ""
	vim.o.winbar = ""

	pcall(vim.diagnostic.enable, false)
	if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
		local ok, enabled = pcall(vim.lsp.inlay_hint.is_enabled)
		if ok then
			terminal_copy_state.inlay_hint_enabled = enabled
		end
		pcall(vim.lsp.inlay_hint.enable, false)
	end

	vim.g.snacks_indent = false
	vim.g.snacks_scope = false

	local ok_ibl, ibl = pcall(require, "ibl")
	if ok_ibl and ibl.update then
		ibl.update({ enabled = false })
	end

	pcall(vim.cmd, "Noice disable")
	pcall(vim.cmd, "NvimTreeClose")
	pcall(vim.cmd, "TroubleClose")
	pcall(vim.cmd, "GitBlameDisable")
	local ok_minimap, minimap = pcall(require, "mini.map")
	if ok_minimap and minimap.close then
		pcall(minimap.close)
	end

	vim.g.terminal_copy_mode = true

	vim.api.nvim_clear_autocmds({ group = terminal_copy_augroup })
	vim.api.nvim_create_autocmd({ "WinNew", "WinEnter", "BufWinEnter" }, {
		group = terminal_copy_augroup,
		callback = function()
			apply_terminal_copy_window(vim.api.nvim_get_current_win())
		end,
	})
end

local function disable_terminal_copy_mode()
	if not terminal_copy_state then
		return
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local opts = terminal_copy_state.windows[win] or terminal_copy_state.default_window
		if opts then
			vim.wo[win].number = opts.number
			vim.wo[win].relativenumber = opts.relativenumber
			vim.wo[win].signcolumn = opts.signcolumn
			vim.wo[win].foldcolumn = opts.foldcolumn
			vim.wo[win].cursorline = opts.cursorline
			vim.wo[win].list = opts.list
			vim.wo[win].colorcolumn = opts.colorcolumn
			vim.wo[win].winbar = opts.winbar
			vim.wo[win].statuscolumn = opts.statuscolumn
		end
	end

	for key, value in pairs(terminal_copy_state.options) do
		vim.o[key] = value
	end

	if terminal_copy_state.diagnostics_enabled ~= nil then
		pcall(vim.diagnostic.enable, terminal_copy_state.diagnostics_enabled)
	end

	if terminal_copy_state.inlay_hint_enabled ~= nil then
		pcall(vim.lsp.inlay_hint.enable, terminal_copy_state.inlay_hint_enabled)
	end

	vim.g.snacks_indent = terminal_copy_state.globals.snacks_indent
	vim.g.snacks_scope = terminal_copy_state.globals.snacks_scope
	if terminal_copy_state.globals.gitblame_enabled ~= nil then
		vim.g.gitblame_enabled = terminal_copy_state.globals.gitblame_enabled
		if
			terminal_copy_state.globals.gitblame_enabled == 1
			or terminal_copy_state.globals.gitblame_enabled == true
		then
			pcall(vim.cmd, "GitBlameEnable")
		else
			pcall(vim.cmd, "GitBlameDisable")
		end
	end

	if terminal_copy_state.ibl_enabled ~= nil then
		local ok_ibl, ibl = pcall(require, "ibl")
		if ok_ibl and ibl.update then
			ibl.update({ enabled = terminal_copy_state.ibl_enabled })
		end
	end

	pcall(vim.cmd, "Noice enable")

	vim.api.nvim_clear_autocmds({ group = terminal_copy_augroup })

	terminal_copy_state = nil
	vim.g.terminal_copy_mode = false
end

local function toggle_terminal_copy_mode()
	if terminal_copy_state then
		disable_terminal_copy_mode()
	else
		enable_terminal_copy_mode()
	end
end

vim.api.nvim_create_user_command("TerminalCopyMode", function(opts)
	local arg = opts.args
	if arg == "on" then
		enable_terminal_copy_mode()
	elseif arg == "off" then
		disable_terminal_copy_mode()
	else
		toggle_terminal_copy_mode()
	end
end, {
	nargs = "?",
	complete = function()
		return { "on", "off", "toggle" }
	end,
	desc = "终端复制模式（隐藏插件 UI）",
})
