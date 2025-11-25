-- lua/plugins/mason-tool-installer-config.lua
-- Mason 工具安装器 - 原生 LSP 模式时启用
return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = true,
    event = vim.g.use_native_lsp and { "BufReadPre", "BufNewFile" } or {},
    dependencies = { "williamboman/mason.nvim" },
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                -- LSP 服务器
                -- "lua-language-server",        -- Lua
                "typescript-language-server", -- TypeScript/JavaScript
                "pyright",                   -- Python
                "rust-analyzer",             -- Rust
                "clangd",                    -- C/C++
                "html-lsp",                  -- HTML
                "css-lsp",                   -- CSS
                "tailwindcss-language-server", -- TailwindCSS
                "json-lsp",                  -- JSON
                "yaml-language-server",      -- YAML
                "bash-language-server",      -- Bash
                "marksman",                  -- Markdown
                "dockerfile-language-server", -- Docker
                "vim-language-server",       -- VimScript
                "powershell-editor-services", -- PowerShell
                "jdtls",      -- Java (可选)
                "phpactor",                  -- PHP
                "omnisharp",                 -- C#
                  -- 格式化工具
                "prettier",                  -- JS/TS/HTML/CSS/JSON/YAML等
                "stylua",                   -- Lua格式化
                "black",                    -- Python格式化
                "rustfmt",                  -- Rust格式化
                "clang-format",             -- C/C++格式化
                "autopep8",                 -- Python格式化(备选)
                "isort",                    -- Python import排序
                  -- 代码检查工具
                "eslint_d",                 -- JavaScript/TypeScript
                "pylint",                   -- Python
                "flake8",                   -- Python
                "shellcheck",               -- Shell脚本
                "hadolint",                 -- Dockerfile
                
                -- 调试适配器
                "local-lua-debugger-vscode", -- Lua调试器
            },
            run_on_start = true, -- 启动时安装
            auto_update = true,
            start_delay = 3000, -- 延迟3秒开始安装，避免启动时卡顿
        })
    end,
}
