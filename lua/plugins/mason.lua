-- lua/plugins/mason-core.lua
-- 临时禁用，切换到 coc.nvim
return {
    "williamboman/mason.nvim",
    enabled = false, -- 禁用此插件
    lazy = false, -- Mason 需要尽早加载
    priority = 1000,
    config = function()
        require("mason").setup({
            ui = {
                border = "rounded",
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
            -- 重要：不在这里配置 mason-lspconfig 或 mason-tool-installer
        })
    end,
}