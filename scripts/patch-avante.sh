#!/bin/bash
# Avante.nvim 本地补丁脚本
# 用于修复 avante.nvim 的一些已知问题
# 
# 使用方法: 
#   chmod +x ~/.config/nvim/scripts/patch-avante.sh
#   ~/.config/nvim/scripts/patch-avante.sh
#
# 注意: 每次更新 avante.nvim 后需要重新运行此脚本

set -e

AVANTE_DIR="${HOME}/.local/share/nvim/lazy/avante.nvim"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Avante.nvim 补丁脚本 ===${NC}"
echo ""

# 检查 avante 目录是否存在
if [ ! -d "$AVANTE_DIR" ]; then
    echo -e "${RED}错误: Avante.nvim 目录不存在: $AVANTE_DIR${NC}"
    echo "请先安装 avante.nvim 插件"
    exit 1
fi

# 注意: 以下补丁 0a 和 0b 已被移除，因为它们会破坏 ACP 功能
# 要控制 AI 的行为，请使用 system_prompt 或 gemini-cli 的 settings.json

ACP_CLIENT_FILE="$AVANTE_DIR/lua/avante/libs/acp_client.lua"

# ============================================================
# 补丁 1: acp_client.lua - 添加 authMethod 到 initialize 请求
# 修复: gemini-cli 新版本需要在初始化时知道认证方式
# ============================================================
echo -e "${YELLOW}[1/4] 应用补丁: acp_client.lua - authMethod${NC}"

if [ -f "$ACP_CLIENT_FILE" ]; then
    # 检查是否已经应用过补丁
    if grep -q "authMethod = self.config.auth_method" "$ACP_CLIENT_FILE"; then
        echo -e "${GREEN}  ✓ 补丁已存在，跳过${NC}"
    else
        # 在 clientCapabilities = self.capabilities, 后添加 authMethod
        sed -i '/clientCapabilities = self.capabilities,/a\    authMethod = self.config.auth_method,' "$ACP_CLIENT_FILE"
        echo -e "${GREEN}  ✓ 补丁已应用${NC}"
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $ACP_CLIENT_FILE${NC}"
fi

# ============================================================
# 补丁 2: acp_client.lua - 继承所有系统环境变量
# 修复: gemini-cli 需要完整环境变量（特别是 HOME）才能找到 oauth 凭证
# ============================================================
echo -e "${YELLOW}[2/4] 应用补丁: acp_client.lua - 环境变量继承${NC}"

if [ -f "$ACP_CLIENT_FILE" ]; then
    # 检查是否已经应用过补丁
    if grep -q "Start with ALL system environment variables" "$ACP_CLIENT_FILE"; then
        echo -e "${GREEN}  ✓ 补丁已存在，跳过${NC}"
    else
        # 创建临时 Lua 脚本来应用补丁
        cat > /tmp/patch_avante_env.lua << 'LUAEOF'
local file_path = os.getenv("HOME") .. "/.local/share/nvim/lazy/avante.nvim/lua/avante/libs/acp_client.lua"
local file = io.open(file_path, "r")
if not file then
    print("Error: Cannot open file")
    os.exit(1)
end
local content = file:read("*all")
file:close()

-- 查找并替换环境变量处理代码
local old_pattern = [[    %-%- Start with system environment and override with config env
    local final_env = {}

    local path = vim%.fn%.getenv%("PATH"%)
    if path then final_env%[#final_env %+ 1%] = "PATH=" %.%. path end

    if env then
      for k, v in pairs%(env%) do
        final_env%[#final_env %+ 1%] = k %.%. "=" %.%. v
      end
    end]]

local new_code = [[    -- Start with ALL system environment variables
    local final_env = {}
    local system_env = vim.fn.environ()
    for k, v in pairs(system_env) do
      final_env[#final_env + 1] = k .. "=" .. v
    end

    -- Override with config env
    if env then
      for k, v in pairs(env) do
        -- Remove existing key if present
        for i = #final_env, 1, -1 do
          if final_env[i]:match("^" .. k .. "=") then
            table.remove(final_env, i)
            break
          end
        end
        final_env[#final_env + 1] = k .. "=" .. v
      end
    end]]

-- 简单的字符串替换（使用固定字符串而不是模式）
local old_str = [[    -- Start with system environment and override with config env
    local final_env = {}

    local path = vim.fn.getenv("PATH")
    if path then final_env[#final_env + 1] = "PATH=" .. path end

    if env then
      for k, v in pairs(env) do
        final_env[#final_env + 1] = k .. "=" .. v
      end
    end]]

local new_content, count = content:gsub(old_str:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1"), new_code)

if count > 0 then
    local out = io.open(file_path, "w")
    out:write(new_content)
    out:close()
    print("Patch applied successfully")
else
    print("Pattern not found or already patched")
end
LUAEOF
        nvim --headless -c "luafile /tmp/patch_avante_env.lua" -c "qa" 2>/dev/null || true
        
        # 验证补丁
        if grep -q "Start with ALL system environment variables" "$ACP_CLIENT_FILE"; then
            echo -e "${GREEN}  ✓ 补丁已应用${NC}"
        else
            echo -e "${YELLOW}  ⚠ 补丁可能未完全应用，请手动检查${NC}"
        fi
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $ACP_CLIENT_FILE${NC}"
fi

# ============================================================
# 补丁 3: openai.lua - 修复 content 为 nil 的问题
# 修复: copilot provider 中 tool_result 的 content 字段可能为 nil
# ============================================================
echo -e "${YELLOW}[3/4] 应用补丁: openai.lua - content nil fix${NC}"

OPENAI_FILE="$AVANTE_DIR/lua/avante/providers/openai.lua"

if [ -f "$OPENAI_FILE" ]; then
    # 检查是否已经应用过补丁
    if grep -q '(item.content or "")' "$OPENAI_FILE"; then
        echo -e "${GREEN}  ✓ 补丁已存在，跳过${NC}"
    else
        # 修复 content 可能为 nil 的问题
        sed -i 's/item\.is_error and "Error: " \.\. item\.content or item\.content/item.is_error and "Error: " .. (item.content or "") or (item.content or "")/g' "$OPENAI_FILE"
        
        # 验证补丁
        if grep -q '(item.content or "")' "$OPENAI_FILE"; then
            echo -e "${GREEN}  ✓ 补丁已应用${NC}"
        else
            echo -e "${YELLOW}  ⚠ 补丁可能未完全应用，请手动检查${NC}"
        fi
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $OPENAI_FILE${NC}"
fi

# ============================================================
# 补丁 4: render.lua - 长行自动换行（带边框装饰）
# 修复: 代码块中的长行换行后没有 │ 前缀
# ============================================================
echo -e "${YELLOW}[4/4] 应用补丁: render.lua - 长行自动换行${NC}"

RENDER_FILE="$AVANTE_DIR/lua/avante/history/render.lua"

if [ -f "$RENDER_FILE" ]; then
    # 检查是否已经应用过补丁
    if grep -q "wrap_and_insert_lines" "$RENDER_FILE"; then
        echo -e "${GREEN}  ✓ 补丁已存在，跳过${NC}"
    else
        # 创建临时文件来存储补丁内容
        cat > /tmp/patch_render.lua << 'LUAEOF'
local file_path = os.getenv("HOME") .. "/.local/share/nvim/lazy/avante.nvim/lua/avante/history/render.lua"
local file = io.open(file_path, "r")
if not file then
    print("Error: Cannot open file")
    os.exit(1)
end
local content = file:read("*all")
file:close()

-- 辅助函数
local helper_functions = [[

---Get the width of avante sidebar
---@return number
local function get_sidebar_width()
  local Config = require("avante.config")
  local width = Config.windows.width
  if type(width) == "number" then
    if width < 1 then
      return math.floor(vim.o.columns * width)
    end
    return width
  end
  return 40  -- default fallback
end

---Helper function to wrap long lines and insert into lines table
---@param lines avante.ui.Line[]
---@param decoration string
---@param text string
---@param highlight string | nil
local function wrap_and_insert_lines(lines, decoration, text, highlight)
  local max_width = get_sidebar_width()
  local deco_width = vim.fn.strdisplaywidth(decoration)
  local available_width = max_width - deco_width - 2
  if available_width < 20 then available_width = 20 end
  
  local text_width = vim.fn.strdisplaywidth(text)
  if text_width <= available_width then
    if highlight then
      table.insert(lines, Line:new({ { decoration }, { text, highlight } }))
    else
      table.insert(lines, Line:new({ { decoration }, { text } }))
    end
    return
  end
  
  -- Word-aware wrapping
  local words = vim.split(text, " ", { plain = true })
  local current_line = ""
  local current_width = 0
  
  for _, word in ipairs(words) do
    local word_width = vim.fn.strdisplaywidth(word)
    if current_width == 0 then
      current_line = word
      current_width = word_width
    elseif current_width + 1 + word_width <= available_width then
      current_line = current_line .. " " .. word
      current_width = current_width + 1 + word_width
    else
      if highlight then
        table.insert(lines, Line:new({ { decoration }, { current_line, highlight } }))
      else
        table.insert(lines, Line:new({ { decoration }, { current_line } }))
      end
      current_line = word
      current_width = word_width
    end
  end
  
  if current_line ~= "" then
    if highlight then
      table.insert(lines, Line:new({ { decoration }, { current_line, highlight } }))
    else
      table.insert(lines, Line:new({ { decoration }, { current_line } }))
    end
  end
end

]]

-- 在 local M = {} 后插入
local marker = "local M = {}"
local pos = content:find(marker, 1, true)
if pos then
    local end_pos = pos + #marker
    content = content:sub(1, end_pos) .. helper_functions .. content:sub(end_pos + 1)
end

-- 替换模式
local replacements = {
    { 
        "table.insert(lines, Line:new({ { decoration }, { line } }))", 
        "wrap_and_insert_lines(lines, decoration, line, nil)" 
    },
    { 
        "table.insert(lines, Line:new({ { decoration }, { line, Highlights.TO_BE_DELETED_WITHOUT_STRIKETHROUGH } }))", 
        "wrap_and_insert_lines(lines, decoration, line, Highlights.TO_BE_DELETED_WITHOUT_STRIKETHROUGH)" 
    },
    { 
        "table.insert(lines, Line:new({ { decoration }, { line, Highlights.INCOMING } }))", 
        "wrap_and_insert_lines(lines, decoration, line, Highlights.INCOMING)" 
    },
    {
        "table.insert(lines, Line:new({ { decoration }, { text_line } }))",
        "wrap_and_insert_lines(lines, decoration, text_line, nil)"
    },
}

for _, rep in ipairs(replacements) do
    local old, new = rep[1], rep[2]
    local escaped_old = old:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
    content = content:gsub(escaped_old, new)
end

-- 写入
local out = io.open(file_path, "w")
out:write(content)
out:close()
print("Done!")
LUAEOF
        nvim --headless -c "luafile /tmp/patch_render.lua" -c "qa" 2>/dev/null || true
        
        # 验证补丁
        if grep -q "wrap_and_insert_lines" "$RENDER_FILE"; then
            echo -e "${GREEN}  ✓ 补丁已应用${NC}"
        else
            echo -e "${YELLOW}  ⚠ 补丁可能未完全应用，请手动检查${NC}"
        fi
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $RENDER_FILE${NC}"
fi

# ============================================================
# 补丁 5: sidebar.lua - 修复单行消息 retry 无效的 bug
# 修复: content_lines 只有一行时被 slice 成空，导致 retry/edit 失败
# ============================================================
echo -e "${YELLOW}[5/5] 应用补丁: sidebar.lua - 单行消息 retry 修复${NC}"

SIDEBAR_FILE="$AVANTE_DIR/lua/avante/sidebar.lua"

if [ -f "$SIDEBAR_FILE" ]; then
    # 检查是否已经应用过补丁
    if grep -q "Only remove last line if there are multiple lines" "$SIDEBAR_FILE"; then
        echo -e "${GREEN}  ✓ 补丁已存在，跳过${NC}"
    else
        # 修复单行消息问题
        sed -i 's/content_lines = vim.list_slice(content_lines, 1, #content_lines - 1)/-- Fix: Only remove last line if there are multiple lines (bug fix for single-line messages)\n  if #content_lines > 1 then\n    content_lines = vim.list_slice(content_lines, 1, #content_lines - 1)\n  end/' "$SIDEBAR_FILE"
        
        # 验证补丁
        if grep -q "Only remove last line if there are multiple lines" "$SIDEBAR_FILE"; then
            echo -e "${GREEN}  ✓ 补丁已应用 - 单行消息 retry 已修复${NC}"
        else
            echo -e "${YELLOW}  ⚠ 补丁可能未完全应用，请手动检查${NC}"
        fi
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $SIDEBAR_FILE${NC}"
fi

# ============================================================
# 补丁 6: init.lua - 修复 ACP stop 无法正常工作的 bug
# 修复: get_registered_acp_clients() 返回错误变量导致 stop 找不到客户端
# ============================================================
echo -e "${YELLOW}[6/6] 应用补丁: init.lua - ACP stop 修复${NC}"

INIT_FILE="$AVANTE_DIR/lua/avante/init.lua"

if [ -f "$INIT_FILE" ]; then
    # 修复 get_registered_acp_clients
    if grep -q "return M._acp_clients or {}" "$INIT_FILE"; then
        sed -i 's/return M._acp_clients or {}/return M.acp_clients or {}/' "$INIT_FILE"
        echo -e "${GREEN}  ✓ 修复 get_registered_acp_clients${NC}"
    else
        echo -e "${GREEN}  ✓ get_registered_acp_clients 已修复，跳过${NC}"
    fi
    
    # 修复 clear_acp_clients
    if grep -q "M._acp_clients = {}" "$INIT_FILE"; then
        sed -i 's/M._acp_clients = {}/M.acp_clients = {}/' "$INIT_FILE"
        echo -e "${GREEN}  ✓ 修复 clear_acp_clients${NC}"
    else
        echo -e "${GREEN}  ✓ clear_acp_clients 已修复，跳过${NC}"
    fi
else
    echo -e "${RED}  ✗ 文件不存在: $INIT_FILE${NC}"
fi

echo ""
echo -e "${GREEN}=== 补丁应用完成 ===${NC}"
echo ""
echo "补丁说明:"
echo "  1. authMethod: 修复 gemini-cli 新版本的认证问题"
echo "  2. 环境变量: 修复 gemini-cli 无法找到 oauth 凭证的问题"
echo "  3. content nil: 修复 copilot provider 的 nil 字段错误"
echo "  4. 长行换行: 代码块中的长行自动换行并保留 │ 前缀"
echo "  5. 单行 retry: 修复单行消息无法 retry/edit 的问题"
echo "  6. ACP stop: 修复 stop 变量名错误导致找不到 ACP 客户端"
echo "  7. sidebar 状态: 修复 stop 后 UI 卡在 generating 状态 (需手动应用)"
echo ""
echo -e "${YELLOW}注意: 每次更新 avante.nvim 后需要重新运行此脚本${NC}"
echo -e "${YELLOW}补丁 7 需要手动修改 llm.lua，无法通过 sed 自动应用${NC}"
