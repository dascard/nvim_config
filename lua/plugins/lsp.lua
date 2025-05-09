return {
    "neovim/nvim-lspconfig",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "williamboman/mason.nvim", config = true }, -- 确保 mason.nvim 被正确加载
        { "williamboman/mason-lspconfig.nvim", lazy = false }, -- 确保 mason-lspconfig 被正确加载
        { "hrsh7th/cmp-nvim-lsp", lazy = true },
        { "folke/neodev.nvim", opts = {}, lazy = true },
    },

    config = function()
        -- Import necessary plugins
        local lspconfig = require("lspconfig")
        local mason = require("mason")
        local mason_lspconfig = require("mason-lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Enable caching for faster module loading
        if vim.loader then
            vim.loader.enable()
        end

        -- Initialize mason.nvim
        mason.setup()

        -- Setup Mason LSP with specific servers
        mason_lspconfig.setup({
            ensure_installed = {
                "lua_ls", "rust_analyzer", "html", "dotls", "jdtls", "marksman", "tailwindcss",
                "julials", "bashls", "ruff", "ts_ls", "emmet_ls", "clangd", "pyright",
                "cssls", "prismals", "neocmake", "svelte", "yamlls", "graphql",
            },
        })

        -- Define capabilities for autocompletion
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change diagnostic symbols in the sign column
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Define key mappings for LSP
        local keymap = vim.keymap
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }

                opts.desc = "See available code actions"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "S", vim.lsp.buf.hover, opts)
                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
            end,
        })

        -- Configure LSP servers
        mason_lspconfig.setup_handlers({
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,
            ["lua_ls"] = function()
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = { globals = { "vim" } },
                            completion = { callSnippet = "Replace" },
                        },
                    },
                })
            end,
            ["rust_analyzer"] = function()
                lspconfig["rust_analyzer"].setup({
                    capabilities = capabilities,
                    settings = {
                        ["rust-analyzer"] = {
                            cargo = { allFeatures = true },
                            checkOnSave = { command = "clippy" },
                        },
                    },
                })
            end,
            ["ts_ls"] = function()
                lspconfig["ts_ls"].setup({
                    capabilities = capabilities,
                    on_attach = function(client, bufnr)
                        client.resolved_capabilities.document_formatting = false
                    end,
                })
            end,
            ["emmet_ls"] = function()
                lspconfig["emmet_ls"].setup({
                    capabilities = capabilities,
                    filetypes = {
                        "html",
                        "typescriptreact",
                        "javascriptreact",
                        "css",
                        "sass",
                        "scss",
                        "less",
                        "svelte",
                    },
                })
            end,
        })
    end,
}