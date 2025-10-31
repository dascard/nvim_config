return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPost", "BufNewFile" },
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"c",
					"lua",
					"cpp",
					"rust",
					"bash",
					"cmake",
					"python",
					"markdown",
					"markdown_inline",
					-- "latex",
					"html",
					"java",
					"typst",
				},
				sync_install = true,
				folder = { enable = true },
				highlight = {
					enable = true,
				},
			})
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		config = function()
			require("treesitter-context").setup({
				enable = true,                   -- Enable this plugin
				throttle = true,                 -- Throttles the update, default to false
				max_lines = 0,                   -- How many lines the context should occupy, 0 for unlimited
				min_rows = 8,                    -- Minimum number of screen rows to enable this plugin
				line_as_cursor = false,          -- When line_as_cursor is true, the cursor line is not an actual line, but a border
				separate_gitsigns = false,       -- Will leave room for gitsigns for example (default true)
				multiline_whitespace_check = false, -- For functions with a multiline signature with just whitespaces (like function (a,\n b,\n c) )
				remove_signcolumn_highlight = false, -- Remove signcolumn highlight of the context line (default true)
				mode = "auto",                   -- 'topline', 'cursor', 'auto', 'nvim_treesitter_context_line', 'nvim_treesitter_context_line_cursor'
			})
		end,
		requires = "nvim-treesitter/nvim-treesitter",
	},
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		after = "nvim-treesitter", -- 确保在 nvim-treesitter 之后加载
		config = function()
			require("nvim-treesitter.configs").setup({
				textobjects = {
					select = {
						enable = true,
						lookahead = true, -- automatically jump to the next matching textobject
						keymaps = {
							-- You can use the default textobjects here
							-- or define your own
							["af"] = "@function.outer",
							["if"] = "@function.inner",
							["ac"] = "@class.outer",
							["ic"] = "@class.inner",
						},
					},
					move = {
						enable = true,
						set_jumps = true,      -- whether to set jumps in the jumplist
						goto_next_start = {
							["]m"] = "@function.outer", -- 下一个函数开始
							["]M"] = "@class.outer", -- 下一个类开始
						},
						goto_next_end = {
							["]e"] = "@function.outer", -- 下一个函数结束
							["]E"] = "@class.outer", -- 下一个类结束
						},
						goto_previous_start = {
							["[m"] = "@function.outer", -- 上一个函数开始
							["[M"] = "@class.outer", -- 上一个类开始
						},
						goto_previous_end = {
							["[e"] = "@function.outer", -- 上一个函数结束
							["[E"] = "@class.outer", -- 上一个类结束
						},
					},
				},
			})
		end,
		requires = "nvim-treesitter/nvim-treesitter",
	},
}
