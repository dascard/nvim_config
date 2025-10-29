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
local random_header = preset_header[math.random(#preset_header)]
return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		-- your configuration comes here
		-- or leave it empty to use the default settings
		-- refer to the configuration section below
		bigfile = { enabled = true },
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
				enabled = true,   -- enable indent guides
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
				open = false,         -- show open fold icons
				git_hl = false,       -- use Git Signs hl for fold icons
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
							{ win = "list",    border = "none" },
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
						{ win = "input",   height = 1,          border = "bottom" },
						{ win = "list",    border = "none" },
						{ win = "preview", title = "{preview}", height = 0.4,     border = "top" },
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
			timeout = 5000,
			width = { min = 40, max = 0.4 },
			height = { min = 1, max = 0.6 },
			-- editor margin to keep free. tabline and statusline are taken into account automatically
			margin = { top = 0, right = 1, bottom = 0 },
			padding = true,           -- add 1 cell of left/right padding to the notification window
			sort = { "level", "added" }, -- sort by level and time
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
			style = "compact",
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
			edge = true,   -- include the edge of the scope (typically the line above and below with smaller indent)
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
			{
				border = "rounded",
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
					winblend = 25, -- 增加通知历史透明度
				},
				keys = { q = "close" },
			},
			-- 通知弹窗
			{
				border = "rounded",
				zindex = 100,
				ft = "markdown",
				wo = {
					winblend = 30, -- 增加通知弹窗透明度
					wrap = false,
					conceallevel = 2,
					colorcolumn = "",
				},
				bo = { filetype = "snacks_notif" },
			},
			picker = {
				winblend = 100, -- 窗口透明度（0-100）
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
				relative = "editor",
				noautocmd = true,
				row = 2,
				relative = "cursor",
				-- row = -3,
				-- col = 0,
				wo = {
					winhighlight = "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
					cursorline = false,
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
					i_esc = { "<esc>", { "cmp_close", "stopinsert" }, mode = "i", expr = true },
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
			"<leader>b",
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
		Snacks.input.enable()
	end,
}
