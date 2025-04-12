return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup({
				check_ts = true,
			})
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")
			npairs.add_rules({
				Rule("$", "$", { "tex", "latex", "typst" }):with_cr(cond.none()),
			})
			npairs.add_rules({
				Rule("$$", "$$", { "tex", "latex", "typst" }):with_cr(cond.none()),
			})
			npairs.add_rules({
				Rule("( ", " )", { "tex", "latex", "typst" }):with_pair(cond.none()),
			})
		end,
	},
	{
		"kylechui/nvim-surround",
		event = "VeryLazy",
		opts = {},
	},
	{
		"catgoose/nvim-colorizer.lua",
		event = "User FilePost",
		opts = {},
	},
}
