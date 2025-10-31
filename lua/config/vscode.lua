local ok, vscode = pcall(require, "vscode")
if not ok then
    vim.notify("无法加载 VSCode Neovim API", vim.log.levels.ERROR)
    return
end
local map = vim.keymap.set

-- pcall(require, "core.options")
-- pcall(require, "core.autocmds")
-- pcall(require, "plugins.search-complete")

local function resolve_args(value)
    if type(value) == "function" then
        return value()
    end
    return value
end

local function map_action(mode, lhs, action, opts)
    opts = opts or {}
    opts.remap = false
    opts.silent = opts.silent ~= false
    local args = opts.args
    opts.args = nil
    map(mode, lhs, function()
        local payload = resolve_args(args)
        vim.schedule(function()
            if payload ~= nil then
                vscode.action(action, payload)
            else
                vscode.action(action)
            end
        end)
    end, opts)
end

local function n(lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    opts.remap = false
    map("n", lhs, rhs, opts)
end

local function v(lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    opts.remap = false
    map("v", lhs, rhs, opts)
end

local function i(lhs, rhs, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    opts.remap = false
    map("i", lhs, rhs, opts)
end

local function notify_unavailable(feature)
    return function()
        vim.notify(string.format("当前 VSCode 配置未提供 %s", feature), vim.log.levels.INFO)
    end
end

-- 窗口与光标管理
n("<Left>", "<C-w>h")
n("<Right>", "<C-w>l")
n("<Up>", "<C-w>k")
n("<Down>", "<C-w>j")
n("<C-x>", "<C-w>x")
n("H", "0")
n("L", "$")
n("J", "15j")
n("K", function()
    local ok_hover = pcall(vscode.action, "editor.action.showHover")
    if not ok_hover then
        vim.cmd("normal! 15k")
    end
end, { desc = "向上 15 行或显示悬浮" })
-- n("j", "gj")
-- n("k", "gk")
n("<C-e>", "%")
n("<M-o>", "o<Esc>")
n("Q", "gqap")

-- 搜索与替换
n("<leader>ss", ":%s/", { desc = "全局搜索替换" })
n("<leader>sl", ":s/", { desc = "当前行搜索替换" })
n("/", function() return "/" end, { expr = true, desc = "搜索" })
n("?", function() return "?" end, { expr = true, desc = "反向搜索" })
n("*", "*zz", { desc = "搜索当前单词并居中" })
n("#", "#zz", { desc = "反向搜索当前单词并居中" })
n("n", "nzzzv", { desc = "下一个搜索结果并居中" })
n("N", "Nzzzv", { desc = "上一个搜索结果并居中" })
n("<Esc>", ":nohlsearch<CR>", { desc = "清除搜索高亮" })
n("<leader>sr", function()
    local current_word = vim.fn.expand("<cword>")
    if current_word ~= "" then
        return ":%s/\\<" .. current_word .. "\\>/"
    end
    return ":%s/"
end, { expr = true, desc = "替换当前单词" })
v("<leader>ss", ":s/", { desc = "选区搜索替换" })
v("<leader>sr", function()
    vim.cmd('normal! "vy')
    local selected = vim.fn.getreg('v')
    selected = vim.fn.escape(selected, '/\\')
    return ":s/" .. selected .. "/"
end, { expr = true, desc = "替换选中文本" })

-- 可视模式编辑
v("<C-j>", ":m '>+1<CR>gv=gv")
v("<C-k>", ":m '<-2<CR>gv=gv")
v("<Tab>", ">gv")
v("<S-Tab>", "<gv")
v("H", "0")
v("L", "$")
v("J", "15j")
v("K", "15k")

-- 插入模式习惯
i("jk", "<Esc>")
i("<leader>a", "<Esc>A")
i("<leader>i", "<Esc>I")
i(",", ",<c-g>u")
i(".", ".<c-g>u")
i(";", ";<c-g>u")
i("<C-o>", "<Esc>o")

-- Copilot（依赖 VS Code 扩展）
map_action("i", "<C-]>", "editor.action.inlineSuggest.showNext", { desc = "Copilot 下一个建议" })
map_action("i", "<C-}>", "editor.action.inlineSuggest.showPrevious", { desc = "Copilot 上一个建议" })

-- VS Code Explorer / 文件管理
map_action("n", "<leader>e", "workbench.view.explorer", { desc = "打开资源管理器" })
map_action("n", "<leader>F", "workbench.action.quickOpen", { desc = "快速打开文件" })

-- 缓冲区与编辑器管理
-- map_action("n", "<M-[>", "workbench.action.previousEditorInGroup", { desc = "上一个缓冲区" })
-- map_action("n", "<M-]>", "workbench.action.nextEditorInGroup", { desc = "下一个缓冲区" })
map_action("n", "<leader>[", "workbench.action.previousEditorInGroup", { desc = "上一个缓冲区" })
map_action("n", "<leader>]", "workbench.action.nextEditorInGroup", { desc = "下一个缓冲区" })
map_action("n", "[B", "workbench.action.moveEditorLeftInGroup", { desc = "缓冲区左移" })
map_action("n", "]B", "workbench.action.moveEditorRightInGroup", { desc = "缓冲区右移" })
map_action("n", "<leader>bp", "workbench.action.pinEditor", { desc = "固定缓冲区" })
map_action("n", "<leader>bP", "workbench.action.closeUnpinnedEditors", { desc = "关闭未固定缓冲区" })
map_action("n", "<leader>br", "workbench.action.closeEditorsToTheRight", { desc = "关闭右侧缓冲区" })
map_action("n", "<leader>bl", "workbench.action.closeEditorsToTheLeft", { desc = "关闭左侧缓冲区" })
map_action("n", "<leader>w", "workbench.action.closeActiveEditor", { desc = "关闭当前缓冲区" })
-- 标签页
map_action("n", "<M-n>", "workbench.action.nextEditorInGroup", { desc = "下一个标签页" })
map_action("n", "<M-p>", "workbench.action.previousEditorInGroup", { desc = "上一个标签页" })

map_action("n", "<leader>b", "workbench.action.showAllEditors", { desc = "搜索缓冲区" })
map_action("n", "<leader>rt", "workbench.action.openRecent", { desc = "最近文件" })
map_action("n", "<leader>qf", "workbench.actions.view.problems", { desc = "问题列表" })
map_action("n", "<leader>dg", "workbench.actions.view.problems", { desc = "诊断" })
map_action("n", "<leader>ud", "workbench.action.showAllEditorsByMostRecentlyUsed", { desc = "撤销历史/最近编辑" })
map_action("n", "<leader>sb", "workbench.action.gotoSymbol", { desc = "当前文件符号" })
map_action("n", "<leader>sB", "workbench.action.showAllSymbols", { desc = "工作区符号" })
map_action("n", "<M-k>", "workbench.action.showCommands", { desc = "命令面板" })
map_action("n", "<leader>fo", "workbench.action.files.openFileFolder", { desc = "打开文件/文件夹" })

-- Git
map_action("n", "git", "workbench.view.scm", { desc = "Git 视图" })
map_action("n", "<leader>gl", "git.viewHistory", { desc = "Git 日志" })
map_action("n", "<leader>gb", "git.checkout", { desc = "切换分支" })

-- TODO / Trouble 样式
map_action("n", "]t", "workbench.action.problems.focus", { desc = "下一个 TODO/问题" })
map_action("n", "[t", "workbench.action.problems.focus", { desc = "上一个 TODO/问题" })
map_action("n", "<leader>xt", "workbench.actions.view.problems", { desc = "打开问题面板" })
map_action("n", "<leader>xT", "workbench.actions.view.problems", { desc = "问题列表 (全部)" })
map_action("n", "<leader>st", "workbench.action.findInFiles", { desc = "搜索 TODO" })

-- 注释
map_action("n", "<leader>?", "editor.action.blockComment", { desc = "切换块注释" })
map_action("x", "<leader>?", "editor.action.blockComment", { desc = "切换块注释" })

-- 全局搜索
map_action("n", "<leader>/", "workbench.action.findInFiles", { desc = "全局搜索" })

-- 格式化 / Lint
map_action("n", "<leader>=", "editor.action.formatDocument", { desc = "格式化文档" })
map_action("x", "<leader>=", "editor.action.formatSelection", { desc = "格式化选区" })
map_action("n", "<leader>l", "editor.action.codeAction", { desc = "代码检查" })

-- 诊断与修复
map_action("n", "]d", "editor.action.marker.next", { desc = "下一个诊断" })
map_action("n", "[d", "editor.action.marker.prev", { desc = "上一个诊断" })
map_action("n", "]c", "workbench.action.compareEditor.nextChange", { desc = "下一个变更" })
map_action("n", "[c", "workbench.action.compareEditor.previousChange", { desc = "上一个变更" })
map_action("n", "<leader>ca", "editor.action.quickFix", { desc = "快速修复" })
map_action("n", "<leader>cf", "editor.action.quickFix", { desc = "快速修复" })
map_action("n", "<leader>cF", "editor.action.fixAll", { desc = "修复全部" })

-- LSP 导航
map_action("n", "gd", "editor.action.revealDefinition", { desc = "跳转到定义" })
map_action("n", "gD", "editor.action.peekDeclaration", { desc = "预览声明" })
map_action("n", "gi", "editor.action.goToImplementation", { desc = "跳转到实现" })
map_action("n", "gr", "editor.action.goToReferences", { desc = "查看引用" })
map_action("n", "gR", "references-view.findReferences", { desc = "引用列表" })
map_action("n", "<leader>rn", "editor.action.rename", { desc = "重命名符号" })
map_action("n", "<leader>co", "editor.action.sourceAction", { desc = "源代码操作" })
map_action("n", "<leader>D", "editor.action.goToTypeDefinition", { desc = "类型定义" })
-- map_action("n", "<leader>wa", "workbench.action.files.addToWorkspace", { desc = "添加工作区文件夹" })
-- map_action("n", "<leader>wr", "workbench.action.removeRootFolder", { desc = "移除工作区文件夹" })
-- map_action("n", "<leader>wl", "workbench.action.openWorkspace", { desc = "列出工作区" })

-- 折叠
map_action("n", "zO", "editor.unfoldAll", { desc = "展开全部" })
map_action("n", "zC", "editor.foldAll", { desc = "折叠全部" })
map_action("n", "zr", "editor.unfold", { desc = "展开一层" })
map_action("n", "zm", "editor.fold", { desc = "折叠一层" })
map_action("n", "zo", "editor.unfold", { desc = "展开" })
map_action("n", "zc", "editor.fold", { desc = "折叠" })
map_action("n", "<leader>K", "editor.action.peekDefinition", { desc = "预览折叠内容" })

-- 调试
map_action("n", "<F5>", "workbench.action.debug.start", { desc = "启动/继续调试" })
map_action("n", "<leader>dp", "editor.debug.action.toggleBreakpoint", { desc = "切换断点" })
map_action("n", "<leader>dc", "workbench.action.debug.continue", { desc = "继续" })
map_action("n", "<leader>dtc", "editor.debug.action.runToCursor", { desc = "运行到光标" })
map_action("n", "<leader>dT", "workbench.action.debug.stop", { desc = "终止调试" })
map_action("n", "<leader>di", "workbench.action.debug.stepInto", { desc = "单步进入" })
map_action("n", "<leader>do", "workbench.action.debug.stepOut", { desc = "单步跳出" })
map_action("n", "<leader>dr", "workbench.debug.action.toggleRepl", { desc = "切换 REPL" })
map_action("n", "<leader>de", "workbench.action.debug.run", { desc = "运行上次" })
map_action("n", "<leader>ds", "workbench.debug.action.toggleRepl", { desc = "切换 REPL" })
map_action("n", "<leader>dx", "workbench.debug.action.closeRepl", { desc = "关闭 REPL" })
map_action("n", "<F6>", "workbench.action.debug.restart", { desc = "重新调试" })
map_action("n", "<leader>du", "workbench.action.debug.openView", { desc = "调试面板" })

-- 终端
map_action("n", "<F12>", "workbench.action.terminal.toggleTerminal", { desc = "切换终端" })
map_action("n", "<leader>ft", "workbench.action.terminal.new", { desc = "新建终端" })
map_action("n", "<leader>k", "workbench.action.terminal.kill", { desc = "终止终端" })

-- 任务 & 项目
map_action("n", "\\t", "workbench.action.tasks.runTask", { desc = "运行任务" })
map_action("n", "<leader>pr", "workbench.action.openRecent", { desc = "项目列表" })

