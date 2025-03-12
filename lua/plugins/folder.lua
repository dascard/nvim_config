return {
	-- Treesitter，确保折叠能正确工作
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},

	-- pretty-fold.nvim 配置
	{
		"anuvyklack/pretty-fold.nvim",
		lazy = false, -- 立即加载
		config = function()
			require("pretty-fold").setup({
				fill_char = "•",
				sections = {
					left = { "content" },
					right = { " ", "number_of_folded_lines", ": ", "percentage", " " },
				},
			})
		end,
	},

	-- 全局 Neovim 折叠设置
	{
		"neovim/nvim-lspconfig",
		config = function()
			vim.opt.foldmethod = "expr" -- {{{
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldenable = true
			vim.opt.foldlevel = 99 -- 默认展开}}}
		end,
	},
}
