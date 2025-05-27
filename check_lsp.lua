-- LSP安装验证脚本
-- 运行方式: :luafile check_lsp.lua

print("=== LSP 服务器状态检查 ===")

local mason_registry = require("mason-registry")
local lspconfig = require("lspconfig")

-- 需要检查的LSP服务器
local lsp_servers = {
    { name = "lua-language-server", lsp_name = "lua_ls", lang = "Lua" },
    { name = "typescript-language-server", lsp_name = "ts_ls", lang = "TypeScript/JavaScript" },
    { name = "pyright", lsp_name = "pyright", lang = "Python" },
    { name = "rust-analyzer", lsp_name = "rust_analyzer", lang = "Rust" },
    { name = "clangd", lsp_name = "clangd", lang = "C/C++" },
    { name = "gopls", lsp_name = "gopls", lang = "Go" },
    { name = "html-lsp", lsp_name = "html", lang = "HTML" },
    { name = "css-lsp", lsp_name = "cssls", lang = "CSS" },
    { name = "json-lsp", lsp_name = "jsonls", lang = "JSON" },
    { name = "yaml-language-server", lsp_name = "yamlls", lang = "YAML" },
    { name = "bash-language-server", lsp_name = "bashls", lang = "Bash" },
    { name = "marksman", lsp_name = "marksman", lang = "Markdown" },
}

print(string.format("%-30s %-20s %-10s", "语言", "Mason包", "状态"))
print(string.rep("-", 60))

for _, server in ipairs(lsp_servers) do
    local mason_installed = mason_registry.is_installed(server.name)
    local status = mason_installed and "✓ 已安装" or "✗ 未安装"
    local color = mason_installed and "✓" or "✗"
    
    print(string.format("%-30s %-20s %s", server.lang, server.name, status))
end

print("\n=== LSP 配置状态 ===")
local active_clients = vim.lsp.get_active_clients()
if #active_clients > 0 then
    print("当前活跃的LSP客户端:")
    for _, client in ipairs(active_clients) do
        print("  - " .. client.name)
    end
else
    print("当前没有活跃的LSP客户端")
end

print("\n运行 :Mason 打开Mason界面进行手动安装")
print("运行 :LspInfo 查看当前缓冲区的LSP状态")
