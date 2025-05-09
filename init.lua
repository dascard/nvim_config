if vim.g.neovide then
	-- Put anything you want to happen only in Neovide here
	vim.o.guifont = "JetBrainsMono Nerd Font:h24"
	vim.o.linespace = 0
	vim.g.neovide_scale_factor = 0.6
	vim.g.neovide_text_gamma = 0.0
	vim.g.neovide_text_contrast = 0.5
	vim.g.neovide_title_background_color =
		string.format("%x", vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg)

	vim.g.neovide_title_text_color = "pink"
	vim.g.neovide_floating_shadow = true
	vim.g.neovide_floating_z_height = 10
	vim.g.neovide_light_angle_degrees = 45
	vim.g.neovide_light_radius = 5
	vim.g.neovide_opacity = 0.8
	vim.g.neovide_normal_opacity = 0.8
	vim.g.neovide_position_animation_length = 0.15
	vim.g.neovide_scroll_animation_length = 0.3
	vim.g.neovide_hide_mouse_when_typing = false
	vim.g.neovide_underline_stroke_scale = 1.0
	vim.g.neovide_refresh_rate = 60
	vim.g.neovide_refresh_rate_idle = 5
	vim.g.neovide_confirm_quit = true
	vim.g.neovide_fullscreen = false
	vim.g.neovide_remember_window_size = true
	vim.g.neovide_cursor_animation_length = 0.150
	vim.g.neovide_cursor_vfx_mode = "pixiedust"
end
local function set_ime(args)
	if args.event:match("Enter$") then
		vim.g.neovide_input_ime = true
	else
		vim.g.neovide_input_ime = false
	end
end

local ime_input = vim.api.nvim_create_augroup("ime_input", { clear = true })

vim.api.nvim_create_autocmd({ "InsertEnter", "InsertLeave" }, {
	group = ime_input,
	pattern = "*",
	callback = set_ime,
})

vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdlineLeave" }, {
	group = ime_input,
	pattern = "[/\\?]",
	callback = set_ime,
})
require("config.lazy")
require("core")
require("core.options")
require("core.keymaps")
require("core.autocmds")
-- require("lazy").setup("plugins")
-- require("lazy").setup("utils")
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
