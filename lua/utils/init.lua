-- utils/init.lua
-- 工具模块初始化

local function safe_require(name)
    local ok, module = pcall(require, name)
    if ok then
        return module
    end

    local message = string.format("utils: 无法加载模块 %s: %s", name, module)
    if vim and vim.schedule and vim.notify and vim.log then
        vim.schedule(function()
            vim.notify(message, vim.log.levels.WARN)
        end)
    end

    return nil
end


local diagnostics = safe_require('utils.diagnostics')
local icons = safe_require('utils.icons')
local dap = safe_require('utils.dap')
local treesitter = safe_require('utils.treesitter')
local coc_symbols = safe_require('utils.coc_symbols')

return {
    diagnostics = diagnostics,
    icons = icons,
    dap = dap,
    treesitter = treesitter,
    coc_symbols = coc_symbols,
}