return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter" }, -- 依赖 treesitter 用于更好的解析
	ft = { "markdown" }, -- 只在 markdown 文件类型中加载
	cmd = { "RenderMarkdownToggle", "RenderMarkdown" }, -- 定义命令，方便手动调用

	config = function()
		-- 配置 render-markdown.nvim
		require("render-markdown").setup({
			-- 你可以根据需要调整以下选项

			-- 渲染方式 ('floating' 或 'split')
			-- 'floating': 在浮动窗口中渲染
			-- 'split': 在新的分屏中渲染 (默认)
			render_style = "floating",

			-- 渲染工具
			-- 'pandoc': 默认使用 pandoc 生成 ansi (纯文本)
			-- 'pandoc_html': 使用 pandoc 生成 html，通过 w3m/lynx 等浏览器在终端显示
			-- 'markdown_to_terminal': 使用 markdown-to-terminal (需要单独安装)
			-- 'glow': 使用 glow (需要单独安装)
			-- 'markdown_cat': 使用 markdown-cat (需要单独安装)
			renderer = "pandoc", -- 默认使用 pandoc 生成 ansi 格式

			-- 图片渲染工具 (仅当 render_style 为 'floating' 时可能更有效)
			-- 'wezterm_imgcat': 使用 wezterm imgcat (推荐，如果使用 wezterm 终端)
			-- 'chafa': 使用 chafa (将图片转为 ASCII 艺术)
			-- 'imgcat_iterm2': 使用 iTerm2 的 imgcat
			img_viewer = "wezterm_imgcat", -- 根据你的终端和安装的工具选择

			-- 其他 pandoc 选项
			pandoc_args = {
				"--wrap=preserve", -- 保持换行符
				"--columns=80", -- 指定输出列宽
				"--top-level-division=chapter",
				"--number-sections",
			},

			-- 浮动窗口配置 (如果 render_style = 'floating')
			floating_window_config = {
				border = "single", -- 边框样式 'single', 'double', 'rounded', 'solid', 'none'
				width = 80, -- 浮动窗口宽度
				height = 30, -- 浮动窗口高度
				relative = "editor", -- 相对于编辑器 'editor' 或 'win'
				row = 5, -- 相对位置
				col = 5,
				-- ... 其他 vim.api.nvim_open_win 的配置
			},

			-- 快捷键绑定 (可选，但推荐)
			keymaps = {
				-- `<leader>md` 切换 Markdown 预览
				toggle = "<leader>md",
				-- `<leader>mr` 强制重新渲染
				render = "<leader>mr",
			},

			-- 自定义高亮组 (可选)
			-- hl_groups = {
			--   -- Markdown 渲染器会输出带有 ANSI 颜色的文本，这里可以定义如何映射这些颜色到 Neovim 的高亮组
			--   -- 例如：
			--   -- RenderMarkdownCode = { fg = "#66FFFF" },
			--   -- RenderMarkdownHeader = { fg = "#FFCC00", bold = true },
			-- },

			-- 渲染后的文件类型 (用于高亮)
			render_filetype = "markdown_render", -- 插件会创建一个特殊的 buffer 类型
		})

		-- 确保 treesitter 为 markdown 文件加载解析器
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "markdown", "markdown_inline" },
			highlight = { enable = true },
		})
	end,
}
