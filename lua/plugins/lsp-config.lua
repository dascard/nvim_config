-- lua/plugins/lsp-config.lua
-- 原生 LSP 配置
return {
    "neovim/nvim-lspconfig",
    -- 不使用 enabled，让 lazy.nvim 可以按需加载
    lazy = true,
    event = vim.g.use_native_lsp and { "BufReadPre", "BufNewFile" } or {},
    dependencies = {
        "williamboman/mason.nvim", -- 确保 mason 已加载，以便 LSP 二进制文件存在
        { "folke/neodev.nvim", opts = {} },
        "b0o/schemastore.nvim", -- JSON/YAML schemas
    },
    config = function()
        local lspconfig = require("lspconfig")
        local configs = require("lspconfig.configs")
        local lspconfig_util = require("lspconfig.util")
        
        -- 检查 lspconfig 是否正常加载
        if not lspconfig then
            vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
            return
        end

        -- 1. 设置 neodev
        require("neodev").setup({})

        -- 2. 定义 LSP 能力 (移动到 SetupNativeLSP 中动态获取)
        -- local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- 3. 定义诊断符号
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- 4. 配置 Neovim 诊断处理
        vim.diagnostic.config({
            virtual_text = true, signs = true, underline = true,
            update_in_insert = false, severity_sort = true,
            float = { border = "rounded", source = "always" },
        })        -- 5. 定义通用的 on_attach 函数
        local common_on_attach = function(client, bufnr)
            -- 修复复制粘贴大段代码时 LSP 崩溃的问题
            -- 通常是由于 semantic tokens 处理不过来导致的
            client.server_capabilities.semanticTokensProvider = nil

            local opts = { buffer = bufnr, noremap = true, silent = true }
            local keymap = vim.keymap
            keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
            keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, opts)
            keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
            keymap.set('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
            keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, opts)
            keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
            keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            keymap.set('n', 'gr', vim.lsp.buf.references, opts)            keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
              -- 支持 aerial.nvim 符号列表 (安全调用)
            if client.server_capabilities.documentSymbolProvider then
                local ok, aerial = pcall(require, "aerial")
                if ok and type(aerial.on_attach) == "function" then
                    aerial.on_attach(bufnr)
                end
            end
        end

        -- 6. 获取 capabilities (与 blink.cmp 集成)
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        local ok, blink = pcall(require, 'blink.cmp')
        if ok then
            capabilities = blink.get_lsp_capabilities(capabilities)
        end

        -- 7. 安全配置 LSP 服务器的辅助函数
        local function safe_setup(server_name, config)
            local ok, err = pcall(function()
                -- 尝试加载配置定义
                local config_def = configs[server_name]
                if not config_def then
                    local ok_req, module = pcall(require, "lspconfig.configs." .. server_name)
                    if ok_req then
                        config_def = module
                    end
                end

                if not config_def then
                     vim.notify("Could not load config for " .. server_name, vim.log.levels.WARN)
                     return
                end

                -- 检查是否支持 vim.lsp.config (Nvim 0.11+)
                if vim.lsp.config and vim.lsp.enable then
                    local default_config = config_def.default_config or {}
                    -- 合并配置
                    local final_config = vim.tbl_deep_extend("force", default_config, config)
                    
                    -- 使用新 API
                    vim.lsp.config(server_name, final_config)
                    vim.lsp.enable(server_name)
                else
                    -- 旧版本回退
                    if lspconfig[server_name] then
                        lspconfig[server_name].setup(config)
                    end
                end
            end)
            
            if not ok then
                vim.notify(
                    string.format("Failed to setup LSP server '%s': %s", server_name, err or "unknown error"),
                    vim.log.levels.WARN
                )
            end
        end

        -- 8. 配置各个 LSP 服务器

        -- Lua
        safe_setup("lua_ls", {
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                Lua = {
                    runtime = { version = "LuaJIT" },
                    diagnostics = { globals = { "vim" } },
                    workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
                    telemetry = { enable = false },
                },
            },
        })

        -- TypeScript / JavaScript
        safe_setup("ts_ls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = function(client, bufnr)
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.documentRangeFormattingProvider = false
                common_on_attach(client, bufnr)
            end,
            settings = {
                typescript = { 
                    inlayHints = { 
                        includeInlayParameterNameHints = 'all', 
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false, 
                        includeInlayFunctionParameterTypeHints = true, 
                        includeInlayVariableTypeHints = true, 
                        includeInlayPropertyDeclarationTypeHints = true, 
                        includeInlayFunctionLikeReturnTypeHints = true, 
                        includeInlayEnumMemberValueHints = true, 
                    } 
                },
                javascript = { 
                    inlayHints = { 
                        includeInlayParameterNameHints = 'all', 
                        includeInlayParameterNameHintsWhenArgumentMatchesName = false, 
                        includeInlayFunctionParameterTypeHints = true, 
                        includeInlayVariableTypeHints = true, 
                        includeInlayPropertyDeclarationTypeHints = true, 
                        includeInlayFunctionLikeReturnTypeHints = true, 
                        includeInlayEnumMemberValueHints = true, 
                    } 
                },
            },
        })

        -- Python
        safe_setup("pyright", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                    },
                },
            },
        })

        -- Rust
        safe_setup("rust_analyzer", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                ["rust-analyzer"] = {
                    cargo = {
                        loadOutDirsFromCheck = true,
                    },
                    procMacro = {
                        enable = true,
                    },
                    checkOnSave = {
                        command = "cargo clippy",
                    },
                },
            },
        })

        -- Go
        safe_setup("gopls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                    staticcheck = true,
                    gofumpt = true,
                },
            },
        })

        -- C/C++
        safe_setup("clangd", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--header-insertion=iwyu",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
            },
        })

        -- JSON
        safe_setup("jsonls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                json = {
                    schemas = require('schemastore').json.schemas(),
                    validate = { enable = true },
                },
            },
        })

        -- YAML
        safe_setup("yamlls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            settings = {
                yaml = {
                    schemaStore = {
                        enable = false,
                        url = "",
                    },
                    schemas = require('schemastore').yaml.schemas(),
                },
            },
        })

        -- PHP
        safe_setup("phpactor", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })

        -- C#
        safe_setup("omnisharp", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        })

        -- PowerShell
        safe_setup("powershell_es", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        })

        -- Docker
        safe_setup("dockerls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })

        -- VimScript
        safe_setup("vimls", {
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })

        -- 其他简单的 LSP 配置
        local simple_servers = {
            "html", "cssls", "tailwindcss", "bashls", "marksman",
        }
        for _, server_name in ipairs(simple_servers) do
            safe_setup(server_name, {
                offset_encoding = "utf-8",
                capabilities = capabilities,
                on_attach = common_on_attach,
            })
        end
    end,
}