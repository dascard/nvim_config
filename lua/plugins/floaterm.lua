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
	config = function()
		local border_fg = "#7aa2f7"

		local function apply_floaterm_highlights()
			vim.api.nvim_set_hl(0, "Floaterm", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "FloatermNC", { bg = "NONE" })
			vim.api.nvim_set_hl(0, "FloatermBorder", { fg = border_fg, bg = "NONE" })
		end

		apply_floaterm_highlights()

		local group = vim.api.nvim_create_augroup("FloatermNoBlend", { clear = true })
		vim.api.nvim_create_autocmd("ColorScheme", {
			group = group,
			callback = apply_floaterm_highlights,
		})

		vim.api.nvim_create_autocmd("User", {
			group = group,
			pattern = "FloatermOpen",
			callback = function()
				vim.api.nvim_set_option_value("winblend", 0, { win = 0 })

				local border_win = vim.b.floaterm_borderwinid
				if type(border_win) == "number" and vim.api.nvim_win_is_valid(border_win) then
					vim.api.nvim_set_option_value("winblend", 0, { win = border_win })
				end
			end,
		})
	end,
}
