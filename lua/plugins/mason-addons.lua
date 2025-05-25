-- lua/plugins/mason-tool-installer-config.lua
return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" }, -- 确保 Mason 先加载
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                "prettier",
                "stylua",
                "black",
                -- 其他你需要的工具
            },
            run_on_start = true, -- 启动时安装
            auto_update = true,
            -- 注意：我们不再有 mason-lspconfig 了，所以任何依赖它的集成可能需要调整
            -- 但 mason-tool-installer 主要关注非 LSP 工具，应该还好
        })
    end,
}