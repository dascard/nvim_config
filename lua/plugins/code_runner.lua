return {
	{
		"skywind3000/asynctasks.vim",
		init = function()
			vim.g.asynctasks_rtp_config = "asynctasks.ini"
			vim.g.asynctasks_extra_config = {}
			vim.g.asynctasks_term_pos = "right"
		end,
	},
	{
		"skywind3000/asyncrun.vim",
		init = function()
			vim.g.asyncrun_open = 10
			vim.g.asyncrun_rootmarks = { ".git", ".svn", ".root", ".project", ".hg" }
			vim.g.asyncrun_save = 2
		end,
	},
	{
		"ibhagwan/fzf-lua",
		lazy = true,
		cmd = "Fzf",
		-- optional for icon support
		dependencies = { "nvim-tree/nvim-web-devicons" },
		-- or if using mini.icons/mini.nvim
		-- dependencies = { "echasnovski/mini.icons" },
		opts = {},
	},
}
