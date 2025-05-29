if vim.g.neovide then
	-- Put anything you want to happen only in Neovide here
	vim.o.guifont = "JetBrainsMono Nerd Font:h24"

	vim.o.linespace = 0
	vim.g.neovide_scale_factor = 0.6
	vim.g.neovide_text_gamma = 0.0
	vim.g.neovide_text_contrast = 0.5
	vim.g.neovide_title_background_color =
		string.format("%x", vim.api.nvim_get_hl(0, { id = vim.api.nvim_get_hl_id_by_name("Normal") }).bg)

	vim.api.nvim_set_keymap(
		"n",
		"<F11>",
		":let g:neovide_fullscreen = !g:neovide_fullscreen<CR>",
		{ noremap = true, silent = true }
	)
	vim.g.neovide_title_text_color = "pink"
	vim.g.neovide_floating_shadow = true
	vim.g.neovide_floating_z_height = 10
	vim.g.neovide_light_angle_degrees = 45
	vim.g.neovide_light_radius = 5
	vim.g.neovide_opacity = 0.8
	vim.g.neovide_normal_opacity = 0.8
	vim.g.neovide_show_border = false
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
local function toggle_neovide_opacity()
	-- 获取当前的透明度值
	local current_opacity = vim.g.neovide_opacity or 0.8 -- 如果未设置，默认为0.8

	-- 判断并切换透明度
	if current_opacity == 0.8 then
		vim.g.neovide_opacity = 0.4
		vim.g.neovide_normal_opacity = 0.4
		print("Neovide opacity set to 0.4")
	else
		vim.g.neovide_opacity = 0.8
		vim.g.neovide_normal_opacity = 0.8
		print("Neovide opacity set to 0.8")
	end
end

-- 创建一个自定义命令 (可选，但推荐，方便调试或手动调用)
vim.api.nvim_create_user_command("ToggleNeovideOpacity", toggle_neovide_opacity, {
  desc = "Toggle Neovide window opacity between 0.8 and 0.4",
})

-- 绑定快捷键 <M-o> (Alt + o) 到这个 Lua 函数
-- 'n': 表示在普通模式下生效
-- 'silent = true': 表示执行时不显示命令
-- 'desc': 为快捷键提供一个描述，方便 `:h user-commands` 查看
vim.keymap.set({"n", "i"}, "<F10>", toggle_neovide_opacity, {
  silent = true,
  desc = "Toggle Neovide Opacity",
})
vim.cmd("highlight Cursor gui=NONE guifg=bg guibg=#ffb6c1")
local function set_ime(args)
	if args.event:match("Enter$") then
		vim.g.neovide_input_ime = true
	else
		vim.g.neovide_input_ime = false
	end
end

local original_notify = vim.notify
-- 请将下面的字符串替换为你从 :messages 中精确复制的错误消息！
local exact_copilot_error_message =
	'[Copilot.lua] RPC[Error] code_name = ServerNotInitialized, message = "Agent service not initialized."'

vim.notify = function(msg, level, opts)
	if type(msg) == "string" and msg == exact_copilot_error_message then
		-- vim.print("Exact match: Suppressed Copilot error: " .. msg) -- 调试用
		return
	end

	-- 如果不是完全匹配，再尝试模式匹配（以防消息中有动态部分，但ServerNotInitialized通常是固定的）
	local copilot_error_pattern =
		'%[Copilot%.lua%] RPC%[Error%] code_name = ServerNotInitialized, message = %"Agent service not initialized%.%"'
	if type(msg) == "string" and string.match(msg, copilot_error_pattern) then
		-- vim.print("Pattern match: Suppressed Copilot error: " .. msg) -- 调试用
		return
	end

	return original_notify(msg, level, opts)
end

local original_print = vim.print
-- 请将下面的字符串替换为你从 :messages 中精确复制的错误消息！
local exact_copilot_error_message_for_print =
	'[Copilot.lua] RPC[Error] code_name = ServerNotInitialized, message = "Agent service not initialized."'

vim.print = function(...)
	local args = { ... }
	local first_arg = args[1]

	if type(first_arg) == "string" then
		-- 尝试从第一个参数中匹配，因为 vim.print 可以接收多个参数
		-- 完整的错误消息可能被拆分或与其他内容混合，这使得过滤更难
		if
			first_arg == exact_copilot_error_message_for_print
			or string.find(first_arg, "Agent service not initialized", 1, true)
		then -- 更宽松的查找
			-- vim.api.nvim_echo({{"Suppressed print: " .. first_arg, "Comment"}}, false, {}) -- 调试
			return
		end
	end
	return original_print(...)
end

-- 包装 vim.echoerr (如果错误是通过它发出的)
local original_echoerr = vim.echoerr
vim.echoerr = function(...)
	local args = { ... }
	local first_arg = args[1]
	if
		type(first_arg) == "string"
		and (
			first_arg == exact_copilot_error_message_for_print
			or string.find(first_arg, "Agent service not initialized", 1, true)
		)
	then
		-- vim.api.nvim_echo({{"Suppressed echoerr: " .. first_arg, "ErrorMsg"}}, false, {}) -- 调试
		return
	end
	return original_echoerr(...)
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
require("core.options")
require("core.keymaps")
require("core.autocmds")
-- require("lazy").setup("plugins")
-- require("lazy").setup("utils")
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree 配置已移至 lua/plugins/ui.lua 中进行 lazy loading

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
