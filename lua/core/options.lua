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
vim.opt.pumheight = 20
vim.opt.foldmethod = "marker"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8
vim.opt.shiftwidth = 4
vim.opt.showmode = false
vim.opt.showtabline = 2
vim.opt.laststatus = 3
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.swapfile = false
vim.opt.cursorline = true
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.timeoutlen = 500
vim.opt.undofile = true
vim.opt.updatetime = 300
vim.opt.writebackup = false
vim.opt.confirm = true

-- 设置 leader 键
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- lua tap=2
vim.api.nvim_create_autocmd("FileType", {
	pattern = "lua",
	callback = function()
		vim.opt_local.shiftwidth = 2
		vim.opt_local.tabstop = 2
	end,
})
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
require("cmp").setup({
	window = {
		completion = {
			winhighlight = "Normal:Pmenu,CursorLine:PmenuSel,Search:None",
		},
		documentation = {
			winhighlight = "Normal:NormalFloat",
		},
	},
})
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
local colors = require("tokyonight.colors").setup()
vim.api.nvim_set_hl(0, "FloatBorder", { fg = colors.comment, bg = colors.bg })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = colors.bg_highlight })

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
