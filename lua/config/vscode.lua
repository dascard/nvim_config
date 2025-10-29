local M = {}

-- Verify we're actually in VS Code
if not vim.g.vscode then
	return M
end

-- Block any attempts to load lazy.nvim or plugin managers
package.loaded["lazy"] = true
package.loaded["lazy.core"] = true
package.loaded["lazy.async"] = true
package.loaded["lazy.manage.runner"] = true
package.loaded["config.lazy"] = true

local function try_require(module)
	-- Blacklist lazy.nvim and plugin-related modules
	local blacklist = {
		"lazy",
		"lazy.core",
		"lazy.async",
		"lazy.manage",
		"config.lazy",
		"plugins.",
	}
	
	for _, pattern in ipairs(blacklist) do
		if module:match("^" .. pattern:gsub("%.", "%%.")) then
			return nil
		end
	end
	
	local ok, result = pcall(require, module)
	if ok then
		return result
	end
	return nil
end

local function apply_vscode_options()
	local opt = vim.opt

	vim.g.mapleader = ";"
	vim.g.maplocalleader = ";"

	vim.cmd("syntax on")
	vim.cmd("filetype indent on")

	opt.backup = false
	opt.clipboard = "unnamedplus"
	opt.cmdheight = 1
	opt.completeopt = { "menuone", "noselect" }
	opt.conceallevel = 2
	opt.fileencoding = "utf-8"
	opt.hlsearch = true
	opt.ignorecase = true
	opt.mouse = "a"
	opt.number = true
	opt.relativenumber = false
	opt.timeoutlen = 400
	opt.updatetime = 200
	opt.scrolloff = 6
	opt.sidescrolloff = 6
	opt.wrap = false
	opt.fillchars = opt.fillchars + { eob = " " }
	opt.signcolumn = "yes"
	opt.termguicolors = true
	opt.undofile = false
	opt.swapfile = false
	opt.writebackup = false
	opt.splitbelow = true
	opt.splitright = true
	opt.cursorline = true
	opt.smartcase = true
	opt.smartindent = true
	opt.tabstop = 2
	opt.shiftwidth = 2
	opt.softtabstop = 2
	opt.expandtab = true
	opt.pumheight = 15
	opt.laststatus = 3
	opt.showmode = false
	opt.showtabline = 0
	opt.pumblend = 20
	opt.winblend = 20

	vim.diagnostic.config({
		virtual_text = false,
		update_in_insert = false,
	})

	if vim.loop.os_uname().sysname:lower():find("windows") then
		opt.shell = "powershell.exe"
		opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
		opt.shellquote = ""
		opt.shellxquote = ""
	end
end

local function apply_basic_keymaps()
	local map = function(mode, lhs, rhs, opts)
		vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true }, opts or {}))
	end

	map("i", "jk", "<Esc>", { desc = "退出插入模式" })
	map("i", "<C-o>", "<Esc>o", { desc = "插入模式快速换行" })
	map("i", ",", ",<c-g>u")
	map("i", ".", ".<c-g>u")
	map("i", ";", ";<c-g>u")
	map("i", "<F5>", "<Esc><F5>")
	map("i", "<leader>a", "<Esc>A")
	map("i", "<leader>i", "<Esc>I")

	map("n", "H", "0")
	map("n", "L", "$")
	map("n", "J", "15j")
	map("n", "<C-u>", "15k")
	map("n", "j", "gj")
	map("n", "k", "gk")
	map("n", "Q", "gqap")
	map("n", "<c-x>", "<c-w>x")
	map("n", "<c-e>", "%")
	map("n", "<M-o>", "o<Esc>")

	map("n", "*", "*zz", { desc = "搜索当前单词并居中" })
	map("n", "#", "#zz", { desc = "反向搜索当前单词并居中" })
	map("n", "n", "nzzzv", { desc = "下一个搜索结果并居中" })
	map("n", "N", "Nzzzv", { desc = "上一个搜索结果并居中" })
	map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "清除搜索高亮" })

	map("n", "<leader>ss", ":%s/", { desc = "全局搜索替换" })
	map("n", "<leader>sl", ":s/", { desc = "当前行搜索替换" })
	map("v", "<leader>ss", ":s/", { desc = "选区搜索替换" })
	map("v", "<C-j>", ":m '>+1<CR>gv=gv")
	map("v", "<C-k>", ":m '<-2<CR>gv=gv")
	map("v", "<Tab>", ">gv")
	map("v", "<S-Tab>", "<gv")
	map("v", "H", "0")
	map("v", "L", "$")
	map("v", "J", "15j")
	map("v", "<C-u>", "15k")
	map("n", "<leader>sr", function()
		local current_word = vim.fn.expand("<cword>")
		if current_word ~= "" then
			return ":%s/\\<" .. current_word .. "\\>/"
		else
			return ":%s/"
		end
	end, { expr = true, desc = "替换当前单词" })
	map("v", "<leader>sr", function()
		vim.cmd('normal! "vy')
		local selected_text = vim.fn.getreg('v')
		selected_text = vim.fn.escape(selected_text, '/\\')
		return ":s/" .. selected_text .. "/"
	end, { expr = true, desc = "替换选中文本" })
end

local function apply_vscode_keymaps()
	local vscode = try_require("vscode")
	if not vscode then
		vim.notify("VS Code API module unavailable", vim.log.levels.WARN)
		return
	end

	local function notify(cmd, args)
		return function()
			if args ~= nil then
				vscode.notify(cmd, args)
			else
				vscode.notify(cmd)
			end
		end
	end

	local function map(mode, lhs, rhs, opts)
		vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { silent = true, noremap = true }, opts or {}))
	end

	map("n", "<left>", notify("workbench.action.focusLeftGroup"), { desc = "窗口左移" })
	map("n", "<right>", notify("workbench.action.focusRightGroup"), { desc = "窗口右移" })
	map("n", "<up>", notify("workbench.action.focusAboveGroup"), { desc = "窗口上移" })
	map("n", "<down>", notify("workbench.action.focusBelowGroup"), { desc = "窗口下移" })

	map("n", "<leader>ff", notify("workbench.action.quickOpen"), { desc = "快速打开文件" })
	map("n", "<leader>F", notify("workbench.action.quickOpen"), { desc = "快速打开文件" })
	map("n", "<C-f>", notify("workbench.action.findInFiles"), { desc = "全局搜索" })
	map("n", "<leader>sw", notify("workbench.action.replaceInFiles"), { desc = "全局替换" })
	map("n", "<leader>sp", notify("editor.action.addSelectionToNextFindMatch"), { desc = "添加下一个匹配" })
	map("n", "<leader>fh", notify("workbench.action.openDocumentationUrl"), { desc = "打开文档" })

	map("n", "<leader>fe", notify("workbench.view.explorer"), { desc = "资源管理器" })
	map("n", "<leader>fr", notify("workbench.action.openRecent"), { desc = "最近项目" })
	map("n", "<leader>tt", notify("workbench.action.terminal.toggleTerminal"), { desc = "切换终端" })
	map("n", "\\t", notify("workbench.action.tasks.runTask"), { desc = "运行任务" })
	map("n", "<leader>k", notify("workbench.action.terminal.kill"), { desc = "关闭终端" })

	map("n", "<leader>cf", notify("editor.action.quickFix"), { desc = "快速修复" })
	map({ "n", "v" }, "<leader>=", notify("editor.action.formatDocument"), { desc = "格式化文档" })
	map("n", "<leader>rn", notify("editor.action.rename"), { desc = "重命名符号" })
	map("n", "<leader>w", notify("workbench.action.files.save"), { desc = "保存文件" })
	map("n", "<leader>q", notify("workbench.action.closeActiveEditor"), { desc = "关闭当前编辑器" })
	map("n", "<leader>Q", notify("workbench.action.closeAllEditors"), { desc = "关闭所有编辑器" })

	map("i", "<C-]>", notify("github.copilot.nextSuggestion"), { desc = "Copilot 下一条" })
	map("i", "<C-}>", notify("github.copilot.previousSuggestion"), { desc = "Copilot 上一条" })
end

function M.setup()
	apply_vscode_options()
	apply_basic_keymaps()
	apply_vscode_keymaps()
end

return M
