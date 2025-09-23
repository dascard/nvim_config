return {
	"stevearc/conform.nvim",
	dependencies = { "mason.nvim" },
	lazy = true,
	cmd = "ConformInfo",
	enabled = false,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				svelte = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				graphql = { "prettier" },
				liquid = { "prettier" },
				cpp = { "clang-format" },
				cmake = { "cmake-format" },
				lua = { "stylua" },
				python = { "isort", "black" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			},
		})

		-- vim.keymap.set({ "n", "v" }, "<leader>=", function()
		-- 	conform.format({
		-- 		lsp_fallback = true,
		-- 		async = false,
		-- 		timeout_ms = 1000,
		-- 	})
		-- end, { desc = "Format file or range (in visual mode)" })
	end,
}
