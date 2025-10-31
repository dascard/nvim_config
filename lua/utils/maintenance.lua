-- Neovim 配置简单维护工具
-- 作者: dascard

local M = {}

local function print_info(msg)
    print("INFO: " .. msg)
end

local function print_error(msg)  
    print("ERROR: " .. msg)
end

-- 清理插件缓存
function M.clean_cache()
    print_info("Cleaning plugin cache...")
    
    local cache_dir = vim.fn.stdpath('cache')
    local data_dir = vim.fn.stdpath('data')
    
    -- 清理 lazy.nvim 缓存
    local lazy_dir = data_dir .. '/lazy'
    if vim.fn.isdirectory(lazy_dir) == 1 then
        vim.fn.delete(lazy_dir, 'rf')
        print_info("Cleaned lazy.nvim cache")
    end
    
    -- 清理其他缓存
    if vim.fn.isdirectory(cache_dir) == 1 then
        vim.fn.delete(cache_dir, 'rf')
        print_info("Cleaned general cache")
    end
end

-- 更新插件
function M.update_plugins()
    print_info("Updating plugins...")
    
    -- 更新 Lazy.nvim 插件
    local lazy_ok, lazy = pcall(require, 'lazy')
    if lazy_ok then
        lazy.sync()
        print_info("Updated lazy.nvim plugins")
    end
    
    -- 更新 COC 扩展  
    if vim.fn.exists(':CocUpdate') == 2 then
        vim.cmd('CocUpdate')
        print_info("Updated COC extensions")
    end
end

-- 基本健康检查
function M.health_check()
    print_info("Running health check...")
    vim.cmd('checkhealth')
end

-- 简单维护
function M.maintenance()
    print_info("Running maintenance...")
    M.clean_cache()
    M.update_plugins() 
    M.health_check()
    print_info("Maintenance completed")
end

-- 创建简单的维护命令
function M.setup_commands()
    vim.api.nvim_create_user_command('ConfigMaintenance', M.maintenance, {
        desc = '执行基本配置维护'
    })
    vim.api.nvim_create_user_command('ConfigClean', M.clean_cache, {
        desc = '清理插件缓存'
    })
    vim.api.nvim_create_user_command('ConfigUpdate', M.update_plugins, {
        desc = '更新所有插件'
    })
    vim.api.nvim_create_user_command('ConfigCheck', M.health_check, {
        desc = '运行健康检查'
    })
end

-- 自动初始化
M.setup_commands()

return M
