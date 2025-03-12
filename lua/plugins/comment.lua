return {
	{
		"numToStr/Comment.nvim",
		vim.keymap.set(
			"n",
			"<leader><leader>",
			"<cmd>lua require('Comment.api').toggle.linewise.current()<CR>",
			{ desc = "Toggle comment" }
		),
		vim.keymap.set(
			"v",
			"<leader><leader>",
			"<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
			{ desc = "Toggle comment in visual mode" }
		),

		config = function()
			require("Comment").setup()
		end,
	},
}
