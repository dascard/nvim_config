return {
	-----------------------------------------------------------------------------
	-- 1. 终端轻量美化：render-markdown.nvim
	-- 作用：隐藏杂乱的标记符，把标题、列表、代码块边界变得漂亮
	-----------------------------------------------------------------------------
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion", "quarto" },
		opts = {
			latex = {
				enabled = true,
			},
		},
		config = function(_, opts)
			require("render-markdown").setup(opts)
			-- 创建 autogroup
			local markdown_group = vim.api.nvim_create_augroup("MarkdownKeymaps", { clear = true })

			-- 为 markdown 和 quarto 文件设置 keymap
			vim.api.nvim_create_autocmd("FileType", {
				group = markdown_group,
				pattern = { "markdown", "codecompanion", "quarto" },
				callback = function()
					-- 这里添加你的 keymap
					vim.keymap.set(
						"n",
						"<leader>tm",
						":RenderMarkdown buf_toggle<CR>",
						{ buffer = true, desc = "Toggle markdown preview" }
					)
				end,
			})
		end,
	},

	-----------------------------------------------------------------------------
	-- 2. 终端图片/高级渲染：image.nvim (已禁用，改用 snacks.image)
	-----------------------------------------------------------------------------
	{
		"3rd/image.nvim",
		enabled = false,
		build = false,
		opts = {
			processor = "magick_cli",
			backend = "kitty",
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" },
				},
			},
			max_width_window_percentage = 80,
			max_height_window_percentage = 50,
		},
	},

	-----------------------------------------------------------------------------
	-- 3. 浏览器完美预览：markdown-preview.nvim
	-- 作用：处理极其复杂的公式、表格，提供所见即所得的 Web 预览
	-----------------------------------------------------------------------------
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			-- 首次安装时自动下载依赖
			vim.fn["mkdp#util#install"]()
		end,
		keys = {
			{
				"<leader>mp",
				"<cmd>MarkdownPreviewToggle<cr>",
				desc = "切换 Markdown 浏览器预览",
			},
		},
		config = function()
			vim.g.mkdp_auto_start = 0 -- 不要在打开 md 时自动弹窗
			vim.g.mkdp_auto_close = 1 -- 离开 md 文件时自动关闭浏览器标签
			vim.g.mkdp_theme = "dark" -- 默认使用暗色主题预览
		end,
	},
}
