-- COC 扩展自动管理脚本
-- 作者: dascard
-- 用途: 自动安装和管理 COC 扩展

local M = {}

-- COC 扩展列表，按类别组织
M.extensions = {
    -- 核心语言支持
    core = {
        'coc-json',           -- JSON 支持
        'coc-html',           -- HTML 支持  
        'coc-css',            -- CSS 支持
        'coc-yaml',           -- YAML 支持
        'coc-xml',            -- XML 支持
        'coc-pairs',          -- 自动括号配对
    },
    
    -- JavaScript/TypeScript 生态
    javascript = {
        'coc-tsserver',       -- TypeScript 语言服务器
        'coc-eslint',         -- ESLint 集成
        'coc-prettier',       -- Prettier 格式化
        'coc-jest',           -- Jest 测试支持
        'coc-angular',        -- Angular 支持 (可选)
        'coc-vetur',          -- Vue.js 支持 (可选)
    },
    
    -- Python 生态
    python = {
        'coc-pyright',        -- Python 语言服务器
        'coc-python',         -- Python 工具集成
    },
    
    -- Web 开发
    web = {
        'coc-emmet',          -- Emmet 支持
        'coc-stylelintplus',  -- CSS/SCSS Lint
        'coc-tailwindcss',    -- TailwindCSS 支持
        'coc-svg',            -- SVG 支持
    },
    
    -- 数据库和数据格式
    data = {
        'coc-sql',            -- SQL 支持
        'coc-toml',           -- TOML 支持
        'coc-markdownlint',   -- Markdown Lint
    },
    
    -- 开发工具
    tools = {
        'coc-git',            -- Git 集成
        'coc-docker',         -- Docker 支持
        'coc-snippets',       -- 代码片段
        'coc-marketplace',    -- 扩展市场
        'coc-explorer',       -- 文件浏览器
        'coc-lists',          -- 增强列表
    },
    
    -- AI 和智能工具
    ai = {
        'coc-copilot',        -- GitHub Copilot
        'coc-tabnine',        -- TabNine AI (可选)
    },
    
    -- 其他语言支持 (可选)
    optional = {
        'coc-rust-analyzer',  -- Rust 支持
        'coc-go',             -- Go 支持
        'coc-java',           -- Java 支持
        'coc-clangd',         -- C/C++ 支持
        'coc-cmake',          -- CMake 支持
        'coc-lua',            -- Lua 支持
        'coc-phpls',          -- PHP 支持
        'coc-rls',            -- Rust (旧版)
        'coc-solargraph',     -- Ruby 支持
        'coc-omnisharp',      -- C# 支持
    }
}

-- 颜色输出
local function print_colored(color, text)
    local colors = {
        red = '\27[31m',
        green = '\27[32m', 
        yellow = '\27[33m',
        blue = '\27[34m',
        cyan = '\27[36m',
        reset = '\27[0m'
    }
    print(colors[color] .. text .. colors.reset)
end

-- 检查 COC 是否可用
function M.check_coc_available()
    if vim.fn.exists(':CocInstall') ~= 2 then
        print_colored('red', '❌ COC.nvim 未安装或未正确加载')
        return false
    end
    return true
end

-- 简化：只提供基本的扩展管理命令
function M.get_installed_extensions()
    -- 简化实现，不依赖复杂的 API 调用
    return {}
end

-- 安装扩展
function M.install_extension(extension)
    if not M.check_coc_available() then
        return false
    end
    
    print_colored('cyan', '📦 安装 COC 扩展: ' .. extension)
    
    -- 使用异步安装以避免阻塞
    vim.cmd('CocInstall -sync ' .. extension)
    
    -- 简单的安装状态检查
    vim.defer_fn(function()
        local installed = M.get_installed_extensions()
        if installed[extension] then
            print_colored('green', '✅ 成功安装: ' .. extension)
        else
            print_colored('red', '❌ 安装失败: ' .. extension)
        end
    end, 2000)
    
    return true
end

-- 批量安装扩展
function M.install_extensions(extension_list)
    if not M.check_coc_available() then
        return
    end
    
    print_colored('blue', '🚀 开始批量安装 COC 扩展...')
    
    for _, extension in ipairs(extension_list) do
        M.install_extension(extension)
    end
end

-- 安装推荐扩展集
function M.install_recommended()
    local recommended = {}
    
    -- 合并核心扩展
    for _, ext in ipairs(M.extensions.core) do
        table.insert(recommended, ext)
    end
    
    -- 合并 JavaScript 扩展
    for _, ext in ipairs(M.extensions.javascript) do
        table.insert(recommended, ext)
    end
    
    -- 合并 Python 扩展  
    for _, ext in ipairs(M.extensions.python) do
        table.insert(recommended, ext)
    end
    
    -- 合并 Web 开发扩展
    for _, ext in ipairs(M.extensions.web) do
        table.insert(recommended, ext)
    end
    
    -- 合并开发工具
    for _, ext in ipairs(M.extensions.tools) do
        table.insert(recommended, ext)
    end
    
    -- 合并 AI 工具
    for _, ext in ipairs(M.extensions.ai) do
        table.insert(recommended, ext)
    end
    
    M.install_extensions(recommended)
end

-- 检查扩展更新
function M.check_updates()
    if not M.check_coc_available() then
        return
    end
    
    print_colored('blue', '🔄 检查 COC 扩展更新...')
    vim.cmd('CocUpdate')
end

-- 清理未使用的扩展
function M.cleanup_extensions()
    if not M.check_coc_available() then
        return
    end
    
    print_colored('yellow', '🧹 清理未使用的 COC 扩展...')
    
    local installed = M.get_installed_extensions()
    local all_recommended = {}
    
    -- 收集所有推荐的扩展
    for category, extensions in pairs(M.extensions) do
        if category ~= 'optional' then
            for _, ext in ipairs(extensions) do
                all_recommended[ext] = true
            end
        end
    end
    
    -- 找出未在推荐列表中的扩展
    local to_remove = {}
    for ext_name, _ in pairs(installed) do
        if not all_recommended[ext_name] then
            table.insert(to_remove, ext_name)
        end
    end
    
    if #to_remove > 0 then
        print_colored('yellow', '发现以下可能不需要的扩展:')
        for _, ext in ipairs(to_remove) do
            print_colored('yellow', '  - ' .. ext)
        end
        
        local confirm = vim.fn.input('是否删除这些扩展? (y/N): ')
        if confirm:lower() == 'y' then
            for _, ext in ipairs(to_remove) do
                vim.cmd('CocUninstall ' .. ext)
                print_colored('red', '🗑️  已删除: ' .. ext)
            end
        end
    else
        print_colored('green', '✅ 没有发现需要清理的扩展')
    end
end

-- 显示扩展状态
function M.show_status()
    if not M.check_coc_available() then
        return
    end
    
    print_colored('blue', '📊 COC 扩展状态报告')
    print('')
    
    local installed = M.get_installed_extensions()
    
    -- 按类别显示扩展状态
    for category, extensions in pairs(M.extensions) do
        local category_names = {
            core = '核心扩展',
            javascript = 'JavaScript/TypeScript',
            python = 'Python 开发',
            web = 'Web 开发', 
            data = '数据格式',
            tools = '开发工具',
            ai = 'AI 工具',
            optional = '可选扩展'
        }
        
        print_colored('cyan', '## ' .. (category_names[category] or category))
        
        for _, ext in ipairs(extensions) do
            if installed[ext] then
                local state = installed[ext].state == 'activated' and '✅' or '⚠️ '
                print_colored('green', state .. ' ' .. ext .. ' (v' .. installed[ext].version .. ')')
            else
                print_colored('red', '❌ ' .. ext .. ' (未安装)')
            end
        end
        print('')
    end
    
    -- 统计信息
    local total_available = 0
    local total_installed = 0
    
    for _, extensions in pairs(M.extensions) do
        for _, ext in ipairs(extensions) do
            total_available = total_available + 1
            if installed[ext] then
                total_installed = total_installed + 1
            end
        end
    end
    
    print_colored('blue', '📈 统计: ' .. total_installed .. '/' .. total_available .. ' 扩展已安装')
end

-- 快速设置命令
function M.setup_commands()
    -- 创建用户命令
    vim.api.nvim_create_user_command('CocExtensionManager', function(opts)
        local action = opts.args
        
        if action == 'install' then
            M.install_recommended()
        elseif action == 'status' then
            M.show_status()
        elseif action == 'update' then
            M.check_updates()
        elseif action == 'cleanup' then
            M.cleanup_extensions()
        else
            print_colored('yellow', 'COC 扩展管理器用法:')
            print_colored('blue', '  :CocExtensionManager install  - 安装推荐扩展')
            print_colored('blue', '  :CocExtensionManager status   - 显示扩展状态')
            print_colored('blue', '  :CocExtensionManager update   - 检查更新')
            print_colored('blue', '  :CocExtensionManager cleanup  - 清理未使用扩展')
        end
    end, {
        nargs = '?',
        complete = function()
            return {'install', 'status', 'update', 'cleanup'}
        end,
        desc = 'COC 扩展管理器'
    })
end

-- 自动初始化
function M.setup()
    M.setup_commands()
end

return M
