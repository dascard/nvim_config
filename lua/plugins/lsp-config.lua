-- lua/plugins/lsp-config.lua
return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "williamboman/mason.nvim", -- 确保 mason 已加载，以便 LSP 二进制文件存在
        "hrsh7th/cmp-nvim-lsp",
        { "folke/neodev.nvim", opts = {} },
        "b0o/schemastore.nvim", -- JSON/YAML schemas
    },
    config = function()
        local lspconfig = require("lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- 1. 设置 neodev
        require("neodev").setup({})

        -- 2. 定义 LSP 能力
        local capabilities = cmp_nvim_lsp.default_capabilities(vim.lsp.protocol.make_client_capabilities())

        -- 3. 定义诊断符号
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- 4. 配置 Neovim 诊断处理
        vim.diagnostic.config({
            virtual_text = true, signs = true, underline = true,
            update_in_insert = false, severity_sort = true,
            float = { border = "rounded", source = "always" },
        })

        -- 5. 定义通用的 on_attach 函数
        local common_on_attach = function(client, bufnr)
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
            keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, opts)
        end

        -- 6. **手动、显式地配置每个 LSP 服务**
        --    **重要：你现在需要手动确保这些 LSP 已经通过 Mason 安装**        -- Lua
        lspconfig.lua_ls.setup({
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
        })-- TypeScript / JavaScript
        lspconfig.ts_ls.setup({
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
        lspconfig.pyright.setup({
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
        lspconfig.rust_analyzer.setup({
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
        lspconfig.gopls.setup({
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
        lspconfig.clangd.setup({
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
        lspconfig.jsonls.setup({
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
        lspconfig.yamlls.setup({
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
        lspconfig.phpactor.setup({
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })

        -- C#
        lspconfig.omnisharp.setup({
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
        })

        -- PowerShell
        lspconfig.powershell_es.setup({
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
            bundle_path = vim.fn.stdpath("data") .. "/mason/packages/powershell-editor-services",
        })

        -- Docker
        lspconfig.dockerls.setup({
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })

        -- VimScript
        lspconfig.vimls.setup({
            offset_encoding = "utf-8",
            capabilities = capabilities,
            on_attach = common_on_attach,
        })        -- 其他简单的 LSP 配置
        local simple_servers = {
            "html", "cssls", "tailwindcss", "bashls", "marksman",
        }
        for _, server_name in ipairs(simple_servers) do
            if lspconfig[server_name] then
                lspconfig[server_name].setup({
                    offset_encoding = "utf-8",
                    capabilities = capabilities,
                    on_attach = common_on_attach,
                })
            else
                vim.notify("LSP config: server " .. server_name .. " not found in lspconfig.", vim.log.levels.WARN)
            end
        end

        -- YAML LSP 配置（使用 schemastore）
        if lspconfig.yamlls then
            lspconfig.yamlls.setup({
                offset_encoding = "utf-8",
                capabilities = capabilities,
                on_attach = common_on_attach,
                settings = {
                    yaml = {
                        schemas = require("schemastore").yaml.schemas(),
                        validate = true,
                        completion = true,
                    }
                }
            })
        end
    end,
}