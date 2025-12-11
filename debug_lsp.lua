
local server_name = "lua_ls"
local ok, config_module = pcall(require, "lspconfig.configs." .. server_name)
if ok then
    print("Loaded " .. server_name)
    print("Type: " .. type(config_module))
    if type(config_module) == "table" then
        for k, v in pairs(config_module) do
            print("Key: " .. k .. ", Type: " .. type(v))
        end
        if config_module.default_config then
            print("Has default_config")
        end
    end
else
    print("Failed to load " .. server_name)
end

print("vim.lsp.config type: " .. type(vim.lsp.config))
