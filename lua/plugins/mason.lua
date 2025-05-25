-- lua/plugins/mason-core.lua
return {
    "williamboman/mason.nvim",
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