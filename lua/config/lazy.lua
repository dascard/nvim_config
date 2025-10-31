-- Bootstrap lazy.nvim

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

local spec
if vim.g.vscode then
	spec = {}
	local imports = vim.g.vscode_lazy_imports or {}
	for _, module in ipairs(imports) do
		local ok, plugin_spec = pcall(require, module)
		if ok then
			if vim.tbl_islist(plugin_spec) then
				for _, entry in ipairs(plugin_spec) do
					spec[#spec + 1] = entry
				end
			else
				spec[#spec + 1] = plugin_spec
			end
		else
			vim.notify(string.format("无法加载 VSCode 插件模块 %s: %s", module, plugin_spec), vim.log.levels.ERROR)
		end
	end
else
	spec = {
		{ import = "plugins" },
	}
end

-- Setup lazy.nvim
require("lazy").setup({
	spec = spec,
	checker = {
		-- automatically check for plugin updates
		enabled = true,
		notify = false,
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = { colorscheme = { "tokyonight" } },
	-- automatically check for plugin updates
})
