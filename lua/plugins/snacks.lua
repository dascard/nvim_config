vim.env.WEZTERM_PANE = nil
vim.env.WEZTERM_EXECUTABLE = nil
vim.env.TERM_PROGRAM = "kitty"
vim.env.TERM = "xterm-kitty"
-- WSL 下 WezTerm 环境变量不传递，手动声明终端。因宿主机在 Windows 而不在 WSL 内，必须声明 SSH 强制走数据流 (t=d) 而不是文件路径
vim.env.SNACKS_KITTY = "1"
-- vim.env.SNACKS_WEZTERM = "1"
vim.env.SNACKS_SSH = "1"

local function render_notification(buf, notif, ctx)
	local lines = vim.split(tostring(notif.msg or ""), "\n", { plain = true })
	if #lines == 0 then
		lines = { "" }
	end

	local title = vim.trim(notif.title or "")
	local prefix = notif.icon .. (title ~= "" and (" " .. title .. " ") or " ")
	lines[1] = string.rep(" ", vim.fn.strdisplaywidth(prefix)) .. (lines[1] or "")
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	local virt_text = {
		{ notif.icon, ctx.hl.icon },
		{ " " },
	}
	if title ~= "" then
		virt_text[#virt_text + 1] = { title, ctx.hl.title }
		virt_text[#virt_text + 1] = { " " }
	end
	vim.api.nvim_buf_set_extmark(buf, ctx.ns, 0, 0, {
		virt_text = virt_text,
		virt_text_pos = "overlay",
		priority = 10,
	})
end

local function apply_notification_highlights()
	local bg = "#1a1b26"
	local fg = "#c0caf5"
	local levels = {
		Error = "#f7768e",
		Warn = "#e0af68",
		Info = "#7aa2f7",
		Debug = "#565f89",
		Trace = "#565f89",
	}

	vim.api.nvim_set_hl(0, "SnacksNotifierHistory", { fg = fg, bg = bg })
	for level, color in pairs(levels) do
		vim.api.nvim_set_hl(0, "SnacksNotifier" .. level, { fg = fg, bg = bg })
		vim.api.nvim_set_hl(0, "SnacksNotifierIcon" .. level, { fg = color, bg = bg })
		vim.api.nvim_set_hl(0, "SnacksNotifierTitle" .. level, { fg = color, bg = bg, bold = true })
		vim.api.nvim_set_hl(0, "SnacksNotifierBorder" .. level, { fg = color, bg = bg })
		vim.api.nvim_set_hl(0, "SnacksNotifierFooter" .. level, { fg = color, bg = bg })
	end
end

local function clamp_buf_pos(buf, pos)
	if type(pos) ~= "table" then
		return pos
	end
	local lnum = tonumber(pos[1]) or 0
	local col = tonumber(pos[2]) or 0
	if lnum <= 0 then
		return pos
	end

	if not (vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf)) then
		return pos
	end

	local line_count = vim.api.nvim_buf_line_count(buf)
	if line_count < 1 then
		line_count = 1
	end
	if lnum > line_count then
		lnum = line_count
	elseif lnum < 1 then
		lnum = 1
	end

	col = math.max(col, 0)
	local line = ""
	if vim.api.nvim_buf_is_valid(buf) then
		line = vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ""
	end
	col = math.min(col, #line)

	return { lnum, col }
end

local function win_set_numbers(win, number, relativenumber)
	if not (win and vim.api.nvim_win_is_valid(win)) then
		return
	end
	vim.wo[win].number = number
	vim.wo[win].relativenumber = relativenumber
end

local function buf_set_numbers(buf, number, relativenumber)
	if not (buf and vim.api.nvim_buf_is_valid(buf)) then
		return
	end
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		pcall(win_set_numbers, win, number, relativenumber)
	end
end

local function win_disable_numbers_for_terminal(win, expected_buf)
	if not (win and vim.api.nvim_win_is_valid(win)) then
		return
	end
	vim.api.nvim_win_call(win, function()
		local current_buf = vim.api.nvim_win_get_buf(win)
		if expected_buf ~= nil and current_buf ~= expected_buf then
			return
		end
		if
			not (current_buf and vim.api.nvim_buf_is_valid(current_buf) and vim.bo[current_buf].buftype == "terminal")
		then
			return
		end

		if vim.w._snacks_term_saved_number == nil then
			-- Terminal windows often start with `nonumber` from Neovim defaults.
			-- For restoring to a normal buffer, use the global defaults instead of
			-- capturing the current terminal window state.
			vim.w._snacks_term_saved_number = vim.o.number
			vim.w._snacks_term_saved_relativenumber = vim.o.relativenumber
		end
		vim.wo.number = false
		vim.wo.relativenumber = false
	end)
end

local function win_restore_numbers_if_saved(win)
	if not (win and vim.api.nvim_win_is_valid(win)) then
		return
	end
	vim.api.nvim_win_call(win, function()
		if vim.w._snacks_term_saved_number == nil and vim.w._snacks_term_saved_relativenumber == nil then
			return
		end
		local buf = vim.api.nvim_get_current_buf()
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
			return
		end
		vim.wo.number = vim.o.number
		vim.wo.relativenumber = vim.o.relativenumber
		vim.w._snacks_term_saved_number = nil
		vim.w._snacks_term_saved_relativenumber = nil
	end)
end

local function tab_restore_numbers_if_saved(tab)
	if not (tab and vim.api.nvim_tabpage_is_valid(tab)) then
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
		local cfg = vim.api.nvim_win_get_config(win)
		if cfg.relative == "" then
			win_restore_numbers_if_saved(win)
		end
	end
end

local function is_terminal_item(item)
	if not item then
		return false
	end
	if item.buftype == "terminal" then
		return true
	end
	local buf = item.buf
	if buf and vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
		return true
	end
	if type(item.name) == "string" and item.name:match("^term://") then
		return true
	end
	if type(item.file) == "string" and item.file:match("^term://") then
		return true
	end
	return false
end

local function buffers_transform(item)
	if is_terminal_item(item) then
		item.pos = nil
		return item
	end
	if item and item.buf and item.pos then
		item.pos = clamp_buf_pos(item.buf, item.pos)
	end
	return item
end

local function explorer_buffer_items(cwd)
	local root = {
		file = cwd .. "/Open Buffers",
		dir = true,
		open = true,
		text = "Open Buffers",
		sort = "!!open-buffers",
		internal = true,
		_snacks_buffers_root = true,
	}
	local items = {}
	local current_buf = vim.api.nvim_get_current_buf()
	local alternate_buf = vim.fn.bufnr("#")

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
			local file = vim.api.nvim_buf_get_name(buf)
			if file ~= "" then
				local info = vim.fn.getbufinfo(buf)[1]
				local mark = vim.api.nvim_buf_get_mark(buf, '"')
				local flags = {
					buf == current_buf and "%" or (buf == alternate_buf and "#" or ""),
					info.hidden == 1 and "h" or (#(info.windows or {}) > 0) and "a" or "",
					vim.bo[buf].readonly and "=" or "",
					info.changed == 1 and "+" or "",
				}
				items[#items + 1] = {
					buf = buf,
					file = file,
					name = file,
					text = file,
					parent = root,
					flags = table.concat(flags),
					lastused = info.lastused,
					pos = mark[1] ~= 0 and mark or { info.lnum, 0 },
					sort = root.sort .. "#" .. string.format("%04d", #items + 1),
					_snacks_buffer_item = true,
				}
			end
		end
	end

	table.sort(items, function(a, b)
		return (a.lastused or 0) > (b.lastused or 0)
	end)

	return root, items
end

local function workspace_explorer_finder(opts, ctx)
	local explorer = require("snacks.picker.source.explorer").explorer(opts, ctx)
	local root, items
	if ctx.filter:is_empty() then
		root, items = explorer_buffer_items(ctx.picker:cwd())
	end

	return function(cb)
		if items and #items > 0 then
			cb(root)
			for _, item in ipairs(items) do
				cb(item)
			end
		end

		return explorer(cb)
	end
end

local function workspace_explorer_format(item, picker)
	if item._snacks_buffers_root then
		return {
			{ "󰈙 ", "SnacksPickerSpecial", virtual = true },
			{ "Open Buffers", "SnacksPickerSpecial" },
			{ "  [workspace]", "SnacksPickerLabel" },
		}
	end

	if item._snacks_buffer_item then
		local ret = {}
		vim.list_extend(ret, Snacks.picker.format.tree(item, picker))
		ret[#ret + 1] = { "󰈙 ", "SnacksPickerBufNr", virtual = true }
		ret[#ret + 1] = { vim.fn.fnamemodify(item.file, ":t"), "SnacksPickerSpecial", field = "file" }
		if item.flags and item.flags:find("+", 1, true) then
			ret[#ret + 1] = { " ●", "DiagnosticWarn" }
		end
		ret[#ret + 1] = { "  " .. vim.fn.fnamemodify(item.file, ":~:h"), "SnacksPickerDir" }
		ret[#ret + 1] = { "  [buf]", "SnacksPickerLabel", virtual = true }
		return ret
	end

	return Snacks.picker.format.file(item, picker)
end

local function configure_workspace_explorer(opts)
	opts = require("snacks.picker.source.explorer").setup(opts)
	local explorer_actions = require("snacks.explorer.actions").actions
	local explorer_confirm = explorer_actions.confirm
	local explorer_close = explorer_actions.explorer_close

	opts.actions = opts.actions or {}
	opts.actions.confirm = function(picker, item, action)
		if item and item._snacks_buffers_root then
			return
		end
		if item and item._snacks_buffer_item then
			return Snacks.picker.actions.jump(picker, item, action)
		end
		return explorer_confirm(picker, item, action)
	end
	opts.actions.explorer_open_file = function(picker, item, action)
		if not item or item.dir or item._snacks_buffers_root then
			return
		end
		return Snacks.picker.actions.jump(picker, item, action)
	end
	opts.actions.explorer_close = function(picker, item, action)
		if item and (item._snacks_buffers_root or item._snacks_buffer_item) then
			return
		end
		return explorer_close(picker, item, action)
	end
	opts.actions.open_buffers = function()
		Snacks.picker.buffers({
			layout = { preset = "explorer_sidebar", preview = false },
			jump = { close = false, reuse_win = true },
		})
	end

	return opts
end

local function toggle_explorer()
	local explorer = Snacks.picker.get({ source = "explorer", tab = false })[1]
	if explorer and not explorer.closed then
		explorer:close()
		return
	end

	Snacks.explorer()
end

local function terminal_aware_jump(picker, item, action)
	local ok_selected, selected = pcall(function()
		return picker:selected({ fallback = true })
	end)
	if ok_selected and type(selected) == "table" then
		for _, it in ipairs(selected) do
			if is_terminal_item(it) then
				it.pos = nil
			elseif it and it.buf and it.pos then
				it.pos = clamp_buf_pos(it.buf, it.pos)
			end
		end
	end

	local cmd = action and action.cmd or "edit"
	local origin_win = picker and picker.main or nil

	-- Special-case terminal buffers: don't set cursor positions, and prefer
	-- reusing an existing terminal window (Telescope-like behavior).
	local first = ok_selected and selected and selected[1] or nil
	if is_terminal_item(first) and first and first.buf and vim.api.nvim_buf_is_valid(first.buf) then
		local buf = first.buf
		vim.bo[buf].buflisted = true

		if picker.opts.jump and picker.opts.jump.close then
			picker:close()
		else
			vim.api.nvim_set_current_win(picker.main)
		end

		local current_tab = vim.api.nvim_get_current_tabpage()
		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			if vim.api.nvim_win_is_valid(win) then
				local cfg = vim.api.nvim_win_get_config(win)
				if cfg.relative == "" and vim.api.nvim_win_get_tabpage(win) == current_tab then
					vim.api.nvim_set_current_win(win)
					win_disable_numbers_for_terminal(win, buf)
					vim.schedule(function()
						win_disable_numbers_for_terminal(win, buf)
					end)
					return
				end
			end
		end

		local open_cmd = ({
			edit = "buffer",
			split = "sbuffer",
			vsplit = "vert sbuffer",
			tab = "tab sbuffer",
			drop = "buffer",
			tabdrop = "tab sbuffer",
		})[cmd] or "buffer"

		vim.cmd(("%s %d"):format(open_cmd, buf))
		local win = vim.api.nvim_get_current_win()
		win_disable_numbers_for_terminal(win, buf)
		vim.schedule(function()
			win_disable_numbers_for_terminal(win, buf)
		end)
		return
	end

	local actions = require("snacks.picker.actions")
	local ok, err = pcall(actions.jump, picker, item, action or {})
	if not ok then
		if type(err) == "string" and err:match("Cursor position outside buffer") then
			local retry_ok, retry_selected = pcall(function()
				return picker:selected({ fallback = true })
			end)
			if retry_ok and type(retry_selected) == "table" then
				for _, it in ipairs(retry_selected) do
					it.pos = nil
				end
			end
			ok, err = pcall(actions.jump, picker, item, action or {})
		end
	end
	if not ok then
		error(err)
	end

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local opened_is_terminal = vim.bo[buf].buftype == "terminal"

	if opened_is_terminal then
		win_disable_numbers_for_terminal(win, buf)
		vim.schedule(function()
			buf_set_numbers(buf, false, false)
			win_disable_numbers_for_terminal(win, buf)
		end)
		return
	end

	local post_tab = vim.api.nvim_get_current_tabpage()
	local post_win = win
	vim.schedule(function()
		-- Restore for the destination window, and also any other windows in the tab
		-- that were previously "terminal-styled" by Snacks.
		win_restore_numbers_if_saved(post_win)
		tab_restore_numbers_if_saved(post_tab)
	end)
	-- Some Lua callbacks may toggle window options after the jump; run again.
	vim.defer_fn(function()
		pcall(win_restore_numbers_if_saved, post_win)
		pcall(tab_restore_numbers_if_saved, post_tab)
	end, 10)
	end

	local function normalize_dashboard_header(header)
		local lines = vim.split(header, "\n", { plain = true })

		while #lines > 0 and vim.trim(lines[1]) == "" do
			table.remove(lines, 1)
		end
		while #lines > 0 and vim.trim(lines[#lines]) == "" do
			table.remove(lines)
		end

		local common_indent = nil
		for _, line in ipairs(lines) do
			if vim.trim(line) ~= "" then
				local indent = line:match("^%s*") or ""
				if common_indent == nil then
					common_indent = indent
				else
					local idx = 1
					local max_idx = math.min(#common_indent, #indent)
					while idx <= max_idx and common_indent:sub(idx, idx) == indent:sub(idx, idx) do
						idx = idx + 1
					end
					common_indent = common_indent:sub(1, idx - 1)
				end
			end
		end

		if common_indent and common_indent ~= "" then
			for index, line in ipairs(lines) do
				if line:sub(1, #common_indent) == common_indent then
					lines[index] = line:sub(#common_indent + 1)
				end
			end
		end

		local width = 0
		for index, line in ipairs(lines) do
			lines[index] = line:gsub("%s+$", "")
			width = math.max(width, vim.api.nvim_strwidth(lines[index]))
		end

		for index, line in ipairs(lines) do
			local padding = width - vim.api.nvim_strwidth(line)
			lines[index] = line .. string.rep(" ", math.max(padding, 0))
		end

		return table.concat(lines, "\n")
	end

	-- stylua: ignore
local preset_header = {
	[[

  ▀████▀                              ▀███
    ██                                  ██
    ██     ▀███  ▀███   ▄██▀██▄ ▄██▀███ ██  ▄██▀▀██▀   ▀██▀
    ██       ██    ██  ██▀   ▀████   ▀▀ ██ ▄█     ██   ▄█
    ██     ▄ ██    ██  ██     ██▀█████▄ ██▄██      ██ ▄█
    ██    ▄█ ██    ██  ██▄   ▄███▄   ██ ██ ▀██▄     ███
  ██████████ ▀████▀███▄ ▀█████▀ ██████▀████▄ ██▄▄   ▄█
                                                  ▄█
                                                ██▀
	]],
	[[
	██╗     ██╗   ██╗ ██████╗ ███████╗██╗  ██╗██╗   ██╗
	██║     ██║   ██║██╔═══██╗██╔════╝██║ ██╔╝╚██╗ ██╔╝
	██║     ██║   ██║██║   ██║███████╗█████╔╝  ╚████╔╝
	██║     ██║   ██║██║   ██║╚════██║██╔═██╗   ╚██╔╝
	███████╗╚██████╔╝╚██████╔╝███████║██║  ██╗   ██║
	╚══════╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝
	]],
	[[
	░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
	░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░
	▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒
	▒   ▒▒▒▒▒▒▒▒   ▒▒   ▒▒▒▒   ▒▒▒▒▒▒     ▒▒   ▒▒   ▒   ▒▒▒
	▓   ▓▓▓▓▓▓▓▓   ▓▓   ▓▓   ▓▓   ▓▓   ▓▓▓▓▓   ▓   ▓▓▓   ▓   ▓
	▓   ▓▓▓▓▓▓▓▓   ▓▓   ▓   ▓▓▓▓   ▓▓▓    ▓▓     ▓▓▓▓▓▓▓    ▓▓
	▓   ▓▓▓▓▓▓▓▓   ▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓   ▓   ▓   ▓▓▓▓▓▓   ▓▓
	█          ███      ████   █████      ██   ██   ████   ███
	███████████████████████████████████████████████████   ████
	]],
	[[
███                                    ███
███                                    ███
███        ███  ███    ███      █████  ███  ███ ███   ███
███        ███  ███  ███  ███  ███     ███ ███   ███ ███
███        ███  ███ ███    ███   ████  █████       ████
███        ███  ███  ███  ███      ███ ███ ███      ███
██████████   ██████    ███     ██████  ███  ███    ███
                                                  ███
	]],
}
math.randomseed(os.time())
local random_header = normalize_dashboard_header(preset_header[math.random(#preset_header)])
return {
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		dependencies = { "echasnovski/mini.icons" },
		init = function()
		vim.api.nvim_create_autocmd("UIEnter", {
			callback = function()
				local ok, Snacks = pcall(require, "snacks")
				if ok and Snacks.image then
					-- 修复 WSL 环境下除零导致的图片高度挤压/抽象化
					local orig_size = Snacks.image.terminal.size
					Snacks.image.terminal.size = function()
						local sz = orig_size()
						if sz and ((sz.cell_width or 0) == 0 or (sz.cell_height or 0) == 0) then
							sz.cell_width = 9
							sz.cell_height = 18
							sz.width = (sz.columns or 80) * 9
							sz.height = (sz.rows or 24) * 18
						end
						if sz then
							sz.scale = 1
						end
						return sz
					end
				end
			end,
		})
	end,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
		explorer = {
			enabled = true,
			replace_netrw = true,
			trash = true,
		},
		image = {
			enabled = true,
			-- force = true,
			force_kitty = true,
			math = {
				enabled = true, -- enable math expression rendering
				-- in the templates below, `${header}` comes from any section in your document,
				-- between a start/end header comment. Comment syntax is language-specific.
				-- * start comment: `// snacks: header start`
				-- * end comment:   `// snacks: header end`
				typst = {
					tpl = [[
        #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
        #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
        #set text(size: 12pt, fill: rgb("${color}"))
        ${header}
        ${content}]],
				},
				latex = {
					font_size = "large", -- see https://www.sascha-frank.com/latex-font-size.html
					-- for latex documents, the doc packages are included automatically,
					-- but you can add more packages here. Useful for markdown documents.
					packages = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools", "braket" },
					tpl = [[
        \documentclass[preview,border=0pt,varwidth,12pt]{standalone}
        \usepackage{${packages}}
        \begin{document}
        ${header}
        { \${font_size} \selectfont
          \color[HTML]{${color}}
        ${content}}
        \end{document}]],
				},
			},
			doc = {
				-- enable image viewer for documents
				-- a treesitter parser must be available for the enabled languages.
				enabled = true,
				-- render the image inline in the buffer
				-- if your env doesn't support unicode placeholders, this will be disabled
				-- takes precedence over `opts.float` on supported terminals
				-- float = true, -- 光标悬停时弹出悬浮预览窗口
				-- inline = false, -- WezTerm 不支持行内图片，必须关闭该项
				float = false,
				inline = true,
				border = "none",
				winhl = {
					Normal = "NormalFloat",
					FloatBorder = "NormalFloat",
				},
				max_width = 100,
				max_height = 60,
			},
		},
		zen = {
			toggles = {
				dim = true,
				git_signs = false,
				mini_diff_signs = false,
				-- diagnostics = false,
				-- inlay_hints = false,
			},
			show = {
				statusline = false, -- can only be shown when using the global statusline
				tabline = false,
			},
			---@type snacks.win.Config
			win = { style = "zen" },
			--- Callback when the window is opened.
			---@param win snacks.win
			on_open = function(win) end,
			--- Callback when the window is closed.
			---@param win snacks.win
			on_close = function(win) end,
			--- Options for the `Snacks.zen.zoom()`
			---@type snacks.zen.Config
			zoom = {
				toggles = {},
				show = { statusline = true, tabline = true },
				win = {
					backdrop = false,
					width = 0, -- full width
				},
			},
		},
		dashboard = {
			preset = {
				-- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
				---@type fun(cmd:string, opts:table)|nil
				pick = nil,
				-- Used by the `keys` section to show keymaps.
				-- Set your custom keymaps here.
				-- When using a function, the `items` argument are the default keymaps.
				---@type snacks.dashboard.Item[]
				keys = {
					{ icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
					{ icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
					{
						icon = " ",
						key = "g",
						desc = "Find Text",
						action = ":lua Snacks.dashboard.pick('live_grep')",
					},
					{
						icon = " ",
						key = "r",
						desc = "Recent Files",
						action = ":lua Snacks.dashboard.pick('oldfiles')",
					},
					{
						icon = " ",
						key = "c",
						desc = "Config",
						action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
					},
					{ icon = " ", key = "s", desc = "Restore Session", section = "session" },
					{
						icon = "󰒲 ",
						key = "L",
						desc = "Lazy",
						action = ":Lazy",
						enabled = package.loaded.lazy ~= nil,
					},
					{ icon = " ", key = "q", desc = "Quit", action = ":qa" },
				},
				-- Used by the `header` section
				header = random_header,
			},
			enabled = true,
			sections = {
				{ section = "header" },
				{ section = "keys", gap = 1 },
				{ icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = { 2, 2 } },
				{ icon = " ", title = "Projects", section = "projects", indent = 2, padding = 2 },
				{ section = "startup" },
			},
		},
		indent = {
			indent = {
				priority = 1,
				enabled = true, -- enable indent guides
				char = "│",
				only_scope = false, -- only show indent guides of the scope
				only_current = false, -- only show indent guides in the current window
				hl = "SnacksIndent", ---@type string|string[] hl groups for indent guides
				-- can be a list of hl groups to cycle through
				-- hl = {
				--     "SnacksIndent1",
				--     "SnacksIndent2",
				--     "SnacksIndent3",
				--     "SnacksIndent4",
				--     "SnacksIndent5",
				--     "SnacksIndent6",
				--     "SnacksIndent7",
				--     "SnacksIndent8",
				-- },
			},
			-- animate scopes. Enabled by default for Neovim >= 0.10
			-- Works on older versions but has to trigger redraws during animation.
			---@class snacks.indent.animate: snacks.animate.Config
			---@field enabled? boolean
			--- * out: animate outwards from the cursor
			--- * up: animate upwards from the cursor
			--- * down: animate downwards from the cursor
			--- * up_down: animate up or down based on the cursor position
			---@field style? "out"|"up_down"|"down"|"up"
			animate = {
				enabled = vim.fn.has("nvim-0.10") == 1,
				style = "out",
				easing = "linear",
				duration = {
					step = 20, -- ms per step
					total = 500, -- maximum duration
				},
			},
			---@class snacks.indent.Scope.Config: snacks.scope.Config
			scope = {
				enabled = true, -- enable highlighting the current scope
				priority = 200,
				char = "│",
				underline = false, -- underline the start of the scope
				only_current = false, -- only show scope in the current window
				hl = "SnacksIndentScope", ---@type string|string[] hl group for scopes
			},
			chunk = {
				-- when enabled, scopes will be rendered as chunks, except for the
				-- top-level scope which will be rendered as a scope.
				enabled = false,
				-- only show chunk scopes in the current window
				only_current = false,
				priority = 200,
				hl = "SnacksIndentChunk", ---@type string|string[] hl group for chunk scopes
				char = {
					corner_top = "┌",
					corner_bottom = "└",
					-- corner_top = "╭",
					-- corner_bottom = "╰",
					horizontal = "─",
					vertical = "│",
					arrow = ">",
				},
			},
			-- filter for buffers to enable indent guides
			filter = function(buf)
				return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ""
			end,
		},
		statuscolumn = {
			left = { "mark", "sign" }, -- priority of signs on the left (high to low)
			right = { "fold", "git" }, -- priority of signs on the right (high to low)
			folds = {
				open = false, -- show open fold icons
				git_hl = false, -- use Git Signs hl for fold icons
			},
			git = {
				-- patterns to match Git signs
				patterns = { "GitSign", "MiniDiffSign" },
			},
			refresh = 50, -- refresh at most every 50ms
		},
		picker = {
			-- My ~/github/dotfiles-latest/neovim/lazyvim/lua/config/keymaps.lua
			-- file was always showing at the top, I needed a way to decrease its
			-- score, in frecency you could use :FrecencyDelete to delete a file
			-- from the database, here you can decrease it's score
			transform = function(item)
				if not item.file then
					return item
				end
				-- Demote the "lazyvim" keymaps file:
				if item.file:match("lazyvim/lua/config/keymaps%.lua") then
					item.score_add = (item.score_add or 0) - 30
				end
				-- Boost the "neobean" keymaps file:
				-- if item.file:match("neobean/lua/config/keymaps%.lua") then
				--   item.score_add = (item.score_add or 0) + 100
				-- end
				return item
			end,
			-- In case you want to make sure that the score manipulation above works
			-- or if you want to check the score of each file
			debug = {
				scores = false, -- show scores in the list
			},
			-- I like the "ivy" layout, so I set it as the default globaly, you can
			-- still override it in different keymaps
			layout = {
				preset = "ivy",
				-- When reaching the bottom of the results in the picker, I don't want
				-- it to cycle and go back to the top
				cycle = false,
			},
			layouts = {
				explorer_sidebar = {
					preview = "main",
					layout = {
						backdrop = false,
						width = 34,
						min_width = 30,
						height = 0,
						position = "left",
						border = "none",
						box = "vertical",
						{
							win = "input",
							height = 1,
							border = "bottom",
							title = "{title}",
							title_pos = "center",
						},
						{ win = "list", border = "none" },
					},
				},
				-- I wanted to modify the ivy layout height and preview pane width,
				-- this is the only way I was able to do it
				-- NOTE: I don't think this is the right way as I'm declaring all the
				-- other values below, if you know a better way, let me know
				--
				-- Then call this layout in the keymaps above
				-- got example from here
				-- https://github.com/folke/snacks.nvim/discussions/468
				ivy = {
					layout = {
						box = "vertical",
						backdrop = false,
						row = -1,
						width = 0,
						height = 0.5,
						border = "top",
						title = " {title} {live} {flags}",
						title_pos = "left",
						{ win = "input", height = 1, border = "bottom" },
						{
							box = "horizontal",
							{ win = "list", border = "none" },
							{ win = "preview", title = "{preview}", width = 0.5, border = "left" },
						},
					},
				},
				-- I wanted to modify the layout width
				--
				vertical = {
					layout = {
						backdrop = false,
						width = 0.8,
						min_width = 80,
						height = 0.8,
						min_height = 30,
						box = "vertical",
						border = "rounded",
						title = "{title} {live} {flags}",
						title_pos = "center",
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list", border = "none" },
						{ win = "preview", title = "{preview}", height = 0.4, border = "top" },
					},
				},
			},
			matcher = {
				frecency = true,
			},
			win = {
				input = {
					keys = {
						-- to close the picker on ESC instead of going to normal mode,
						-- add the following keymap to your config
						["<Esc>"] = { "close", mode = { "n", "i" } },
						-- I'm used to scrolling like this in LazyGit
						["J"] = { "preview_scroll_down", mode = { "i", "n" } },
						["K"] = { "preview_scroll_up", mode = { "i", "n" } },
						["H"] = { "preview_scroll_left", mode = { "i", "n" } },
						["L"] = { "preview_scroll_right", mode = { "i", "n" } },
					},
				},
			},
			actions = {
				confirm = terminal_aware_jump,
				jump = terminal_aware_jump,
			},
			sources = {
				explorer = {
					finder = workspace_explorer_finder,
					format = workspace_explorer_format,
					watch = true,
					diagnostics = true,
					diagnostics_open = false,
					git_status = true,
					git_status_open = false,
					git_untracked = true,
					follow_file = true,
					layout = { preset = "explorer_sidebar", preview = false },
					config = configure_workspace_explorer,
					exclude = {
						".git",
						"node_modules",
						".venv",
						"venv",
						"__pycache__",
						".mypy_cache",
						".pytest_cache",
						".ruff_cache",
						"dist",
						"build",
					},
					win = {
						input = {
							keys = {
								["<Esc>"] = false,
								["q"] = false,
								["<CR>"] = { "explorer_open_file", mode = { "n", "i" } },
								["<C-b>"] = { "open_buffers", mode = { "n", "i" }, desc = "Open buffers" },
							},
						},
						list = {
							keys = {
								["<Esc>"] = false,
								["q"] = false,
								["<CR>"] = "explorer_open_file",
								["b"] = "open_buffers",
								["o"] = "edit_vsplit",
								["O"] = "explorer_open",
								["<C-t>"] = "explorer_up",
							},
						},
						preview = {
							keys = {
								["<Esc>"] = false,
								["q"] = false,
							},
						},
					},
				},
				buffers = {
					transform = buffers_transform,
					jump = { reuse_win = true },
				},
			},
			formatters = {
				file = {
					filename_first = true, -- display filename before the file path
					truncate = 80,
				},
			},
		},
		input = {
			enabled = true,
			icon = " ",
			icon_hl = "SnacksInputIcon",
			icon_pos = "left",
			prompt_pos = "title",
			win = { style = "input" },
			expand = true,
		},
		notifier = {
			enabled = true,
			timeout = 4000,
			width = { min = 34, max = 0.38 },
			height = { min = 1, max = 0.5 },
			-- editor margin to keep free. tabline and statusline are taken into account automatically
			margin = { top = 1, right = 1, bottom = 0 },
			padding = true, -- add 1 cell of left/right padding to the notification window
			gap = 1,
			sort = { "added" }, -- keep notifications in arrival order
			-- minimum log level to display. TRACE is the lowest
			-- all notifications are stored in history
			level = vim.log.levels.TRACE,
			icons = {
				error = " ",
				warn = " ",
				info = " ",
				debug = " ",
				trace = " ",
			},
			keep = function(notif)
				return vim.fn.getcmdpos() > 0
			end,
			---@type snacks.notifier.style
			style = render_notification,
			top_down = true, -- place notifications from top to bottom
			date_format = "%R", -- time format for notifications
			-- format for footer when more lines are available
			-- `%d` is replaced with the number of lines.
			-- only works for styles with a border
			---@type string|boolean
			more_format = " ↓ %d lines ",
			refresh = 50, -- refresh at most every 50ms
		},
		quickfile = { enabled = true },
		scope = {
			enabled = true,
			-- absolute minimum size of the scope.
			-- can be less if the scope is a top-level single line scope
			min_size = 2,
			-- try to expand the scope to this size
			max_size = nil,
			cursor = true, -- when true, the column of the cursor is used to determine the scope
			edge = true, -- include the edge of the scope (typically the line above and below with smaller indent)
			siblings = false, -- expand single line scopes with single line siblings
			-- what buffers to attach to
			filter = function(buf)
				return vim.bo[buf].buftype == "" and vim.b[buf].snacks_scope ~= false and vim.g.snacks_scope ~= false
			end,
			-- debounce scope detection in ms
			debounce = 30,
			treesitter = {
				-- detect scope based on treesitter.
				-- falls back to indent based detection if not available
				enabled = true,
				injections = true, -- include language injections when detecting scope (useful for languages like `vue`)
				---@type string[]|{enabled?:boolean}
				blocks = {
					enabled = false, -- enable to use the following blocks
					"function_declaration",
					"function_definition",
					"method_declaration",
					"method_definition",
					"class_declaration",
					"class_definition",
					"do_statement",
					"while_statement",
					"repeat_statement",
					"if_statement",
					"for_statement",
				},
				-- these treesitter fields will be considered as blocks
				field_blocks = {
					"local_declaration",
				},
			},
			-- These keymaps will only be set if the `scope` plugin is enabled.
			-- Alternatively, you can set them manually in your config,
			-- using the `Snacks.scope.textobject` and `Snacks.scope.jump` functions.
			keys = {
				---@type table<string, snacks.scope.TextObject|{desc?:string}>
				textobject = {
					ii = {
						min_size = 2, -- minimum size of the scope
						edge = false, -- inner scope
						cursor = false,
						treesitter = { blocks = { enabled = false } },
						desc = "inner scope",
					},
					ai = {
						cursor = false,
						min_size = 2, -- minimum size of the scope
						treesitter = { blocks = { enabled = false } },
						desc = "full scope",
					},
				},
				---@type table<string, snacks.scope.Jump|{desc?:string}>
				jump = {
					["[i"] = {
						min_size = 1, -- allow single line scopes
						bottom = false,
						cursor = false,
						edge = true,
						treesitter = { blocks = { enabled = false } },
						desc = "jump to top edge of scope",
					},
					["]i"] = {
						min_size = 1, -- allow single line scopes
						bottom = true,
						cursor = false,
						edge = true,
						treesitter = { blocks = { enabled = false } },
						desc = "jump to bottom edge of scope",
					},
				},
			},
		},
		scroll = { enabled = true },
		statuscolumn = { enabled = true },
		words = { enabled = true },
		profiler = { enabled = true },
		lazygit = { enabled = true },
		gitbrowse = { enabled = true },
		styles = {
			-- 通知历史窗口
			notification_history = {
				border = "single",
				zindex = 100,
				width = 0.6,
				height = 0.6,
				minimal = false,
				title = " Notification History ",
				title_pos = "center",
				ft = "markdown",
				bo = { filetype = "snacks_notif_history", modifiable = false },
				wo = {
					winhighlight = "Normal:SnacksNotifierHistory",
					winblend = 0,
				},
				keys = { q = "close" },
			},
			-- 通知弹窗
			notification = {
				border = "single",
				zindex = 100,
				ft = "markdown",
				wo = {
					winblend = 0,
					wrap = true,
					linebreak = true,
					conceallevel = 2,
					colorcolumn = "",
				},
				bo = { filetype = "snacks_notif" },
			},
			picker = {
				winblend = 10, -- 降低透明度以增加对比度
				border_style = "rounded", -- 边框样式（none/single/double/rounded）
				title_icon = "", -- 标题区图标（需 nerd font 支持）
				prompt_prefix = "🔍 ", -- 搜索前缀符号
			},
			input = {
				backdrop = false,
				position = "float",
				border = "rounded",
				title_pos = "center",
				height = 1,
				width = 45,
				noautocmd = true,
				row = 2,
				relative = "cursor",
				-- row = -3,
				-- col = 0,
				wo = {
					winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
					cursorline = false,
					winblend = 10, -- 降低透明度以增加对比度
				},
				bo = {
					filetype = "snacks_input",
					buftype = "prompt",
				},
				--- buffer local variables
				b = {
					completion = false, -- disable blink completions in input
				},
				keys = {
					n_esc = { "<esc>", { "cmp_close", "cancel" }, mode = "n", expr = true },
					-- i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
					i_cr = { "<cr>", { "cmp_accept", "confirm" }, mode = { "i", "n" }, expr = true },
					i_tab = { "<tab>", { "cmp_select_next", "cmp" }, mode = "i", expr = true },
					i_ctrl_w = { "<c-w>", "<c-s-w>", mode = "i", expr = true },
					i_up = { "<up>", { "hist_up" }, mode = { "i", "n" } },
					i_down = { "<down>", { "hist_down" }, mode = { "i", "n" } },
					q = "cancel",
				},
			},
		},
	},

	keys = {
		{
			"<leader>e",
			toggle_explorer,
			mode = { "n" },
			desc = "File Explorer",
		},
		{
			"<leader>rt",
			function()
				Snacks.picker.recent()
			end,
			mode = { "n" },
			desc = "Recent Files",
		},
		{
			"git",
			function()
				Snacks.lazygit.open(opts)
			end,
			mode = { "n" },
			desc = "Lazygit",
		},
		{
			"<leader>nf",
			function(opts)
				Snacks.notifier.show_history(opts)
			end,
			mode = { "n" },
			desc = "notify history",
		},
		{
			"<leader>qf",
			function()
				Snacks.picker.qflist()
			end,
			desc = "QuickFix Window",
		},
		{
			"<leader>dg",
			function()
				Snacks.picker.diagnostics()
			end,
			desc = "Diagnostics",
		},
		{
			"<leader>/",
			function()
				Snacks.picker.grep()
			end,
			desc = "Grep",
		},
		{
			"<leader>ud",
			function()
				Snacks.picker.undo()
			end,
			desc = "Undo History",
		},
		{
			"<leader>Z",
			function()
				Snacks.zen()
			end,
			mode = { "n" },
			desc = "zen mode",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.lsp_definitions()
			end,
			desc = "Goto Definition",
		},
		{
			"<leader>gD",
			function()
				Snacks.picker.lsp_declarations()
			end,
			desc = "Goto Declaration",
		},
		{
			"<leader>gr",
			function()
				Snacks.picker.lsp_references()
			end,
			nowait = true,
			desc = "References",
		},
		{
			"<leader>gi",
			function()
				Snacks.picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"<leader>gy",
			function()
				Snacks.picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>sb",
			function()
				Snacks.picker.lsp_symbols()
			end,
			desc = "LSP Symbols",
		},
		{
			"<leader>sB",
			function()
				Snacks.picker.lsp_workspace_symbols()
			end,
			desc = "LSP Workspace Symbols",
		},
		-- Open git log in vertical view
		{
			"<leader>gl",
			function()
				Snacks.picker.git_log({
					finder = "git_log",
					format = "git_log",
					preview = "git_show",
					confirm = "git_checkout",
					layout = "vertical",
				})
			end,
			desc = "Git Log",
		},
		-- -- List git branches with Snacks_picker to quickly switch to a new branch
		{
			"<leader>gb",
			function()
				Snacks.picker.git_branches({
					layout = "select",
				})
			end,
			desc = "Branches",
		},
		-- Used in LazyVim to view the different keymaps, this by default is
		-- configured as <leader>sk but I run it too often
		-- Sometimes I need to see if a keymap is already taken or not
		{
			"<M-k>",
			function()
				Snacks.picker.keymaps({
					layout = "vertical",
				})
			end,
			desc = "Keymaps",
		},
		-- File picker
		{
			"<leader>f",
			function()
				Snacks.picker.files({
					finder = "files",
					format = "file",
					show_empty = true,
					supports_live = true,
					-- In case you want to override the layout for this keymap
					-- layout = "vscode",
				})
			end,
			desc = "Find Files",
		},
		-- Navigate my buffers
		{
			"<leader>B",
			function()
				Snacks.picker.buffers({
					-- I always want my buffers picker to start in normal mode
					on_show = function()
						vim.cmd.stopinsert()
					end,
					finder = "buffers",
					format = "buffer",
					hidden = false,
					unloaded = true,
					current = true,
					sort_lastused = true,
					win = {
						input = {
							keys = {
								["d"] = "bufdelete",
							},
						},
						list = { keys = { ["d"] = "bufdelete" } },
					},
					-- In case you want to override the layout for this keymap
					-- layout = "ivy",
				})
			end,
			desc = "[P]Snacks picker buffers",
		},
	},
	config = function(_, opts)
		require("snacks").setup(opts) -- 标准化配置接口
		apply_notification_highlights()
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = vim.api.nvim_create_augroup("snacks_notification_style", { clear = true }),
			callback = apply_notification_highlights,
		})
		Snacks.input.enable()
	end,
}
