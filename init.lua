require("config.lazy")
require("core")
require("core.options")
require("core.keymaps")
require("core.autocmds")
require("lazy").setup("plugins")
require("lazy").setup("utils")
-- optionally enable 24-bit colour
vim.opt.termguicolors = true
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- empty setup using defaults
require("nvim-tree").setup({
	-- 视图设置
	view = {
		width = 35, -- 侧边栏宽度[5,7](@ref)
		side = "left", -- 显示位置（left/right）
		number = false, -- 隐藏行号
		relativenumber = false,
		signcolumn = "yes", -- 显示图标列
	},
	-- 文件操作行为
	actions = {
		open_file = {
			quit_on_open = false, -- 打开文件后自动关闭树[7](@ref)
			resize_window = true, -- 自适应窗口大小
		},
	},

	-- 过滤文件
	filters = {
		dotfiles = false, -- 隐藏 . 开头的文件[6](@ref)
		custom = { "node_modules" }, -- 自定义隐藏目录
	},
	-- Git 状态集成（需安装 git 插件）
	git = {
		enable = true,
		ignore = false,
	},
})

local function my_on_attach(bufnr)
	local api = require("nvim-tree.api")

	local function opts(desc)
		return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
	end

	-- default mappings
	api.config.mappings.default_on_attach(bufnr)

	-- custom mappings
	vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
	vim.keymap.set("n", "<BS>", api.tree.change_root_to_parent, opts("Up"))
	vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
	vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
	vim.keymap.set("n", "o", api.node.open.vertical, opts("Open: Vertical Split"))
end

-- pass to setup along with your other options
require("nvim-tree").setup({
	---
	on_attach = my_on_attach,
	---
})

vim.opt.fillchars:append({ eob = " " }) -- 全局替换

vim.g.clipboard = {
	name = "win32yank-wsl",
	copy = {
		["+"] = "win32yank.exe -i --crlf",
		["*"] = "win32yank.exe -i --crlf",
	},
	paste = {
		["+"] = "win32yank.exe -o --lf",
		["*"] = "win32yank.exe -o --lf",
	},
	cache_enabled = true,
}

-- init.lua
-- vim.opt.clipboard = "unnamedplus"
-- vim.g.clipboard = {
-- 	name = "OSC 52",
-- 	copy = {
-- 		["+"] = require("vim.ui.clipboard.osc52").copy,
-- 		["*"] = require("vim.ui.clipboard.osc52").copy,
-- 	},
-- 	paste = {
-- 		["+"] = require("vim.ui.clipboard.osc52").paste,
-- 		["*"] = require("vim.ui.clipboard.osc52").paste,
-- 	},
-- }
