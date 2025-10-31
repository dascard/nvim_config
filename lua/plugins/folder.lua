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
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		lazy = false,

		config = function()
			vim.keymap.set("n", "zO", require("ufo").openAllFolds, { desc = "Open all folds" })
			vim.keymap.set("n", "zC", require("ufo").closeAllFolds, { desc = "Close all folds" })
			vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open all folds except current" })
			vim.keymap.set("n", "<leader>K", function()
				local _ = require("ufo").peekFoldedLinesUnderCursor()
			end, {
				desc = "Preview folded maps",
			})
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true,
			}
			-- 移除错误的LSP配置，因为LSP已经在lsp-config.lua中正确配置了
			-- 这里只需要设置folding capabilities，不需要重新配置LSP服务器
			local handler = function(virtText, lnum, endLnum, width, truncate)
				local newVirtText = {}
				local foldedLines = endLnum - lnum
				local suffix = (" 󰁂  %d"):format(foldedLines)
				local sufWidth = vim.fn.strdisplaywidth(suffix)
				local targetWidth = width - sufWidth
				local curWidth = 0

				for _, chunk in ipairs(virtText) do
					local chunkText = chunk[1]
					local chunkWidth = vim.fn.strdisplaywidth(chunkText)
					if targetWidth > curWidth + chunkWidth then
						table.insert(newVirtText, chunk)
					else
						chunkText = truncate(chunkText, targetWidth - curWidth)
						local hlGroup = chunk[2]
						table.insert(newVirtText, { chunkText, hlGroup })
						chunkWidth = vim.fn.strdisplaywidth(chunkText)
						-- str width returned from truncate() may less than 2nd argument, need padding
						if curWidth + chunkWidth < targetWidth then
							suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
						end
						break
					end
					curWidth = curWidth + chunkWidth
				end
				local rAlignAppndx = math.max(math.min(vim.opt.textwidth["_value"], width - 1) - curWidth - sufWidth, 0)
				suffix = (" "):rep(rAlignAppndx) .. suffix
				table.insert(newVirtText, { suffix, "MoreMsg" })
				return newVirtText
			end

			vim.o.foldlevel = 99
			require("ufo").setup({
				fold_virt_text_handler = handler,
			})
		end,
	},
}
