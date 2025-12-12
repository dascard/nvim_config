local M = {}

local function deepcopy(value)
    if type(vim.deepcopy) == "function" then
        return vim.deepcopy(value)
    end

    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, item in pairs(value) do
        copy[key] = deepcopy(item)
    end

    return copy
end

local function deep_extend(base, override)
    local result = deepcopy(base)
    if type(result) ~= "table" then
        result = {}
    end
    if type(override) ~= "table" then
        return result
    end
    for key, value in pairs(override) do
        if type(value) == "table" and type(result[key]) == "table" then
            result[key] = deep_extend(result[key], value)
        else
            result[key] = deepcopy(value)
        end
    end
    return result
end

local severity_map = {
    ERROR = 1,
    WARN = 2,
    INFO = 3,
    HINT = 4,
}

local fallback_state = {
    active = false,
    warned = false,
    store = {},
    namespace_cache = {},
    config = {},
    sign_defined = false,
}

local severity_to_sign = {
    [severity_map.ERROR] = {
        name = "DiagnosticSignError",
        text = "",
        texthl = "DiagnosticSignError",
    },
    [severity_map.WARN] = {
        name = "DiagnosticSignWarn",
        text = "",
        texthl = "DiagnosticSignWarn",
    },
    [severity_map.INFO] = {
        name = "DiagnosticSignInfo",
        text = "",
        texthl = "DiagnosticSignInfo",
    },
    [severity_map.HINT] = {
        name = "DiagnosticSignHint",
        text = "",
        texthl = "DiagnosticSignHint",
    },
}

local severity_to_virtual_text = {
    [severity_map.ERROR] = "DiagnosticVirtualTextError",
    [severity_map.WARN] = "DiagnosticVirtualTextWarn",
    [severity_map.INFO] = "DiagnosticVirtualTextInfo",
    [severity_map.HINT] = "DiagnosticVirtualTextHint",
}

local function notify_fallback()
    if fallback_state.warned then
        return
    end

    fallback_state.warned = true

    if vim.schedule and vim.log then
        vim.schedule(function()
            vim.notify(
                "vim.diagnostic 模块不可用，已启用兼容层。诊断会以简化模式显示。",
                vim.log.levels.WARN
            )
        end)
    end
end

local function ensure_signs()
    if fallback_state.sign_defined then
        return
    end

    if not vim.fn or not vim.fn.sign_define then
        return
    end

    for _, def in pairs(severity_to_sign) do
        local ok, defined = pcall(vim.fn.sign_getdefined, def.name)
        if not ok or not defined or #defined == 0 then
            pcall(vim.fn.sign_define, def.name, {
                text = def.text,
                texthl = def.texthl,
                numhl = def.texthl,
            })
        end
    end

    fallback_state.sign_defined = true
end

local function normalize_namespace(ns)
    if ns == nil then
        ns = "diagnostic_bridge"
    end

    if type(ns) == "number" then
        return ns
    end

    local key = tostring(ns)
    if not fallback_state.namespace_cache[key] then
        fallback_state.namespace_cache[key] = vim.api.nvim_create_namespace(key)
    end

    return fallback_state.namespace_cache[key]
end

local function severity_passes(diag, filter)
    if not filter then
        return true
    end

    local current = diag.severity or severity_map.ERROR

    if type(filter) == "number" then
        return current == filter
    end

    if type(filter) == "table" then
        if filter.min or filter.max then
            local min = filter.min or severity_map.ERROR
            local max = filter.max or severity_map.HINT
            return current >= min and current <= max
        end

        for _, value in ipairs(filter) do
            if current == value then
                return true
            end
        end
        return false
    end

    return true
end

local function fallback_set(ns, bufnr, diagnostics, opts)
    if not vim.api or not vim.api.nvim_buf_clear_namespace then
        return
    end

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    ns = normalize_namespace(ns)

    fallback_state.store[bufnr] = fallback_state.store[bufnr] or {}
    fallback_state.store[bufnr][ns] = deepcopy(diagnostics or {})

    pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)

    if vim.fn and vim.fn.sign_unplace then
        pcall(vim.fn.sign_unplace, "DiagBridge" .. ns, { buffer = bufnr })
    end

    if type(diagnostics) ~= "table" or #diagnostics == 0 then
        return
    end

    ensure_signs()

    local enable_virtual_text = true
    if opts and opts.virtual_text == false then
        enable_virtual_text = false
    end

    for idx, diag in ipairs(diagnostics) do
        local severity = diag.severity or severity_map.ERROR
        local lnum = math.max((diag.lnum or 0), 0)
        local col = math.max((diag.col or 0), 0)

        local sign_def = severity_to_sign[severity]
        if sign_def and vim.fn and vim.fn.sign_place then
            pcall(vim.fn.sign_place, idx, "DiagBridge" .. ns, sign_def.name, bufnr, {
                lnum = lnum + 1,
                priority = (opts and opts.sign_priority) or 10,
            })
        end

        if enable_virtual_text and diag.message and vim.api and vim.api.nvim_buf_set_extmark then
            local hl = severity_to_virtual_text[severity] or "DiagnosticVirtualTextInfo"
            pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, lnum, col, {
                virt_text = { { diag.message, hl } },
                virt_text_pos = (opts and opts.virt_text_pos) or "eol",
                hl_mode = "combine",
            })
        end
    end
end

local function fallback_reset(ns, bufnr)
    if not vim.api or not vim.api.nvim_buf_clear_namespace then
        return
    end

    local function clear_for(buffer, namespace)
        if namespace then
            pcall(vim.api.nvim_buf_clear_namespace, buffer, namespace, 0, -1)
            if vim.fn and vim.fn.sign_unplace then
                pcall(vim.fn.sign_unplace, "DiagBridge" .. namespace, { buffer = buffer })
            end
        else
            if fallback_state.store[buffer] then
                for ns_id, _ in pairs(fallback_state.store[buffer]) do
                    pcall(vim.api.nvim_buf_clear_namespace, buffer, ns_id, 0, -1)
                    if vim.fn and vim.fn.sign_unplace then
                        pcall(vim.fn.sign_unplace, "DiagBridge" .. ns_id, { buffer = buffer })
                    end
                end
            end
        end
    end

    if bufnr then
        if fallback_state.store[bufnr] then
            if ns then
                ns = normalize_namespace(ns)
                fallback_state.store[bufnr][ns] = nil
                clear_for(bufnr, ns)
            else
                clear_for(bufnr)
                fallback_state.store[bufnr] = nil
            end
        end
        return
    end

    for buffer, _ in pairs(fallback_state.store) do
        clear_for(buffer)
    end

    fallback_state.store = {}
end

local function fallback_get(bufnr, opts)
    local result = {}

    local function collect(list)
        if type(list) ~= "table" then
            return
        end
        for _, diag in ipairs(list) do
            if severity_passes(diag, opts and opts.severity) then
                table.insert(result, deepcopy(diag))
            end
        end
    end

    if bufnr then
        local data = fallback_state.store[bufnr]
        if data then
            for _, diagnostics in pairs(data) do
                collect(diagnostics)
            end
        end
    else
        for _, data in pairs(fallback_state.store) do
            for _, diagnostics in pairs(data) do
                collect(diagnostics)
            end
        end
    end

    return result
end

local function fallback_config(opts)
    if not opts then
        return deepcopy(fallback_state.config)
    end

    fallback_state.config = deep_extend(fallback_state.config, opts)
    return fallback_state.config
end

local fallback_module = {
    severity = severity_map,
    config = fallback_config,
    set = fallback_set,
    reset = fallback_reset,
    get = fallback_get,
    is_fallback = function()
        return true
    end,
}

function M.ensure()
    if vim.diagnostic then
        return {
            module = vim.diagnostic,
            fallback = false,
        }
    end

    local ok, diagnostic_mod = pcall(require, "vim.diagnostic")
    if ok and diagnostic_mod then
        vim.diagnostic = diagnostic_mod
        return {
            module = diagnostic_mod,
            fallback = false,
        }
    end

    notify_fallback()

    fallback_state.active = true
    vim.diagnostic = fallback_module

    return {
        module = fallback_module,
        fallback = true,
    }
end

function M.is_fallback()
    return fallback_state.active
end

function M.get_severity_map()
    return severity_map
end

function M.get_store()
    return fallback_state.store
end

return M
