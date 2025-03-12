return {
	"DoDoENT/vimspector-dap",
	requires = {
		{ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } },
		{ "nvim-lua/plenary.nvim" },
	},

	config = function()
		vim.keymap.set("n", "<F5>", require("vimspector-dap").runVimspectorConfigOnDap, { silent = true })
	end,
}
