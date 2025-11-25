-- LSP 切换配置文件
-- 由 ToggleLSP 命令管理
-- 设置为 true 使用原生 LSP + blink.cmp
-- 设置为 false 使用 coc.nvim
vim.g.use_native_lsp = true -- 默认使用 coc.nvim

-- 保存当前模式到文件
local function save_mode_to_file(new_state)
    local config_path = vim.fn.stdpath("config") .. "/lua/lsp_switch.lua"
    local file = io.open(config_path, "r")
    if not file then return false end
    local content = file:read("*all")
    file:close()
    
    -- 替换值
    local new_content = content:gsub(
        "vim%.g%.use_native_lsp = [%a]+",
        "vim.g.use_native_lsp = " .. tostring(new_state)
    )
    
    file = io.open(config_path, "w")
    if not file then return false end
    file:write(new_content)
    file:close()
    return true
end

-- 创建切换命令
vim.api.nvim_create_user_command("ToggleLSP", function()
    local new_state = not vim.g.use_native_lsp
    local mode = new_state and "原生 LSP + blink.cmp" or "coc.nvim"
    
    if save_mode_to_file(new_state) then
        vim.notify("LSP 模式已切换为: " .. mode .. "\n请重启 Neovim 生效 (:qa 退出)", vim.log.levels.WARN)
    else
        vim.notify("保存配置失败！", vim.log.levels.ERROR)
    end
end, { desc = "切换 LSP 模式 (需要重启)" })

-- 创建查看当前模式的命令
vim.api.nvim_create_user_command("LSPMode", function()
    local mode = vim.g.use_native_lsp and "原生 LSP + blink.cmp" or "coc.nvim"
    vim.notify("当前 LSP 模式: " .. mode, vim.log.levels.INFO)
end, { desc = "显示当前 LSP 模式" })

-- 切换到 COC
vim.api.nvim_create_user_command("UseCoc", function()
    if not vim.g.use_native_lsp then
        vim.notify("已经在使用 COC.nvim", vim.log.levels.INFO)
        return
    end
    if save_mode_to_file(false) then
        vim.notify("LSP 模式已切换为: coc.nvim\n请重启 Neovim 生效 (:qa 退出)", vim.log.levels.WARN)
    end
end, { desc = "切换到 COC.nvim (需要重启)" })

-- 切换到原生 LSP
vim.api.nvim_create_user_command("UseNativeLSP", function()
    if vim.g.use_native_lsp then
        vim.notify("已经在使用原生 LSP", vim.log.levels.INFO)
        return
    end
    if save_mode_to_file(true) then
        vim.notify("LSP 模式已切换为: 原生 LSP + blink.cmp\n请重启 Neovim 生效 (:qa 退出)", vim.log.levels.WARN)
    end
end, { desc = "切换到原生 LSP (需要重启)" })
