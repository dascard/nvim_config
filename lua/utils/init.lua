-- utils/init.lua
-- 工具模块初始化

-- 加载维护工具
require('utils.maintenance')

-- 加载COC管理器
require('utils.coc-manager')

return {
    maintenance = require('utils.maintenance'),
    coc_manager = require('utils.coc-manager'),
    icons = require('utils.icons'),
    dap = require('utils.dap')
}