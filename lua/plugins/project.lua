return {
	-- project.nvim
	{
		"ahmedkhalf/project.nvim",
		lazy = false,
		config = function()
			require("project_nvim").setup({
				manual_mode = false,
				detection_methods = { "lsp", "pattern" },
				patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "CMakeLists.txt", "Makefile", "package.json" },
				ignore_lsp = {},
				exclude_dirs = {},
				show_hidden = false,
				silent_chdir = true,
				scope_chdir = "global",
				datapath = vim.fn.stdpath("data"),
			})

			-- 正确的扩展名称是 "projects"
			pcall(require("telescope").load_extension, "projects")
		end,
	},

	-- Telescope 及其依赖
	{
		"nvim-telescope/telescope.nvim",
		lazy = true,
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			vim.api.nvim_set_keymap("n", "<leader>pr", ":Telescope projects<CR>", { noremap = true, silent = true })
		end,
	},
}
