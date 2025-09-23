return {
	{
		'SirVer/ultisnips',
		lazy = true,
		config = function()
			-- UltiSnips 的配置使用全局变量
			vim.g.UltiSnipsExpandTrigger = "<c-;>"
			vim.g.UltiSnipsJumpForwardTrigger = "<c-j>"
			vim.g.UltiSnipsJumpBackwardTrigger = "<c-k>"
			vim.g.UltiSnipsEditSplit = "vertical"
		end,
	}, -- 第二个插件是代码片段库
	{
		"honza/vim-snippets",
		-- 这是一个依赖项，当 UltiSnips 加载时，它也应该被加载
		dependencies = { "SirVer/ultisnips" },
	},
}
