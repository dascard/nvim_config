-- CRITICAL: Block lazy.nvim entirely in VS Code
if vim.g.vscode then
	-- Debug: Confirm we're in VS Code branch
	vim.schedule(function()
		vim.notify("VS Code mode detected - blocking lazy.nvim", vim.log.levels.INFO)
	end)
	
	-- Prevent lazy.nvim from loading
	vim.g.loaded_lazy = 1
	vim.g.loaded_lazy_plugin = 1
	vim.g.loaded_lazy_nvim = 1
	
	-- Block package loading attempts
	package.loaded["lazy"] = true
	package.loaded["lazy.core"] = true
	package.loaded["lazy.async"] = true
	package.loaded["lazy.manage.runner"] = true
	package.loaded["config.lazy"] = true
	
	-- Remove lazy.nvim from runtime path if it exists
	local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
	vim.opt.runtimepath:remove(lazypath)
	
	-- Prevent any plugin/* files from lazy.nvim loading
	vim.api.nvim_create_autocmd("SourcePre", {
		pattern = "**/lazy.nvim/plugin/*.lua",
		callback = function()
			return true  -- Skip loading
		end,
	})
	
	-- Load VS Code specific config
	local ok, err = pcall(require, "config.vscode")
	if ok and type(err) == "table" and err.setup then
		err.setup()
	end
	
	-- Stop all further initialization
	return
end

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
require("utils")  -- 加载工具模块
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- nvim-tree 配置已移至 lua/plugins/ui.lua 中进行 lazy loading

vim.opt.fillchars:append({ eob = " " }) -- 全局替换

-- 智能跨平台剪切板配置
local function setup_clipboard()
    -- 检测操作系统和环境
    local os_name = vim.loop.os_uname().sysname:lower()
    local is_wsl = vim.fn.has('wsl') == 1
    local is_ssh = vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
    local is_tmux = vim.env.TMUX ~= nil
    local is_termux = vim.env.PREFIX ~= nil and vim.env.PREFIX:match('/data/data/com.termux')
    
    -- Termux (Android)
    if is_termux then
        if vim.fn.executable('termux-clipboard-set') == 1 then
            vim.g.clipboard = {
                name = "termux",
                copy = {
                    ["+"] = "termux-clipboard-set",
                    ["*"] = "termux-clipboard-set",
                },
                paste = {
                    ["+"] = "termux-clipboard-get",
                    ["*"] = "termux-clipboard-get",
                },
                cache_enabled = true,
            }
            return
        end
    end
    
    -- Windows (包括 WSL)
    if os_name:match("windows") or is_wsl then
        if vim.fn.executable('win32yank.exe') == 1 then
            vim.g.clipboard = {
                name = "win32yank",
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
            return
        elseif vim.fn.executable('clip.exe') == 1 and vim.fn.executable('powershell.exe') == 1 then
            vim.g.clipboard = {
                name = "win32-powershell",
                copy = {
                    ["+"] = "clip.exe",
                    ["*"] = "clip.exe",
                },
                paste = {
                    ["+"] = 'powershell.exe -c "Get-Clipboard"',
                    ["*"] = 'powershell.exe -c "Get-Clipboard"',
                },
                cache_enabled = true,
            }
            return
        end
    end
    
    -- macOS
    if os_name:match("darwin") then
        if vim.fn.executable('pbcopy') == 1 and vim.fn.executable('pbpaste') == 1 then
            vim.g.clipboard = {
                name = "pbcopy",
                copy = {
                    ["+"] = "pbcopy",
                    ["*"] = "pbcopy",
                },
                paste = {
                    ["+"] = "pbpaste",
                    ["*"] = "pbpaste",
                },
                cache_enabled = true,
            }
            return
        end
    end
    
    -- Linux 和其他 Unix 系统
    if os_name:match("linux") or os_name:match("bsd") or os_name:match("unix") then
        -- 优先使用 wl-copy (Wayland)
        if vim.fn.executable('wl-copy') == 1 and vim.fn.executable('wl-paste') == 1 then
            vim.g.clipboard = {
                name = "wl-clipboard",
                copy = {
                    ["+"] = "wl-copy --type text/plain",
                    ["*"] = "wl-copy --type text/plain --primary",
                },
                paste = {
                    ["+"] = "wl-paste --no-newline",
                    ["*"] = "wl-paste --no-newline --primary",
                },
                cache_enabled = true,
            }
            return
        -- 其次使用 xclip (X11)
        elseif vim.fn.executable('xclip') == 1 then
            vim.g.clipboard = {
                name = "xclip",
                copy = {
                    ["+"] = "xclip -quiet -i -selection clipboard",
                    ["*"] = "xclip -quiet -i -selection primary",
                },
                paste = {
                    ["+"] = "xclip -o -selection clipboard",
                    ["*"] = "xclip -o -selection primary",
                },
                cache_enabled = true,
            }
            return
        -- 最后使用 xsel
        elseif vim.fn.executable('xsel') == 1 then
            vim.g.clipboard = {
                name = "xsel",
                copy = {
                    ["+"] = "xsel --nodetach --input --clipboard",
                    ["*"] = "xsel --nodetach --input --primary",
                },
                paste = {
                    ["+"] = "xsel --output --clipboard",
                    ["*"] = "xsel --output --primary",
                },
                cache_enabled = true,
            }
            return
        end
    end
    
    -- SSH 或远程环境，使用 OSC 52 (如果支持)
    if is_ssh or is_tmux then
        -- 检查终端是否支持 OSC 52
        if vim.env.TERM_PROGRAM or vim.env.TMUX then
            vim.g.clipboard = {
                name = "OSC 52",
                copy = {
                    ["+"] = require("vim.ui.clipboard.osc52").copy,
                    ["*"] = require("vim.ui.clipboard.osc52").copy,
                },
                paste = {
                    ["+"] = require("vim.ui.clipboard.osc52").paste,
                    ["*"] = require("vim.ui.clipboard.osc52").paste,
                },
            }
            return
        end
    end
    
    -- 默认回退到系统剪切板
    vim.opt.clipboard = "unnamedplus"
end

-- 设置剪切板
setup_clipboard()
