return {
	{
		"skywind3000/asynctasks.vim",
	},
	{
		"skywind3000/asyncrun.vim",
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
