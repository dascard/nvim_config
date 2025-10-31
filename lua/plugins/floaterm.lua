-- 使用 lazy.nvim 管理插件[3](@ref)
return {
	"voldikss/vim-floaterm",
	init = function()
		vim.g.floaterm_keymap_toggle = "<F12>"
		vim.g.floaterm_keymap_new = "<leader>ft"
		vim.g.floaterm_autoclose = 1
		vim.g.floaterm_width = 0.8
		vim.g.floaterm_height = 0.8
	end,
}
