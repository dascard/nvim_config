local keymap = vim.keymap.set

-- 功能键映射
-- F3: LSP 符号列表面板 (在 symbols.lua 中配置)

-- 常规模式映射
keymap("n", "<left>", "<C-w>h")
keymap("n", "<right>", "<C-w>l")
keymap("n", "<up>", "<C-w>k")
keymap("n", "<down>", "<C-w>j")
keymap("n", "<leader>ss", ":%s/")
keymap("n", "Q", "gqap")
keymap("n", "L", "$")
keymap("n", "<leader>F", ":FZF<cr>")
keymap("n", "<c-f>", ":Rg<cr>")
keymap("n", "<c-x>", "<c-w>x")
keymap("n", "<c-e>", "%")
keymap("n", "J", "15j")
keymap("n", "<C-u>", "15k") -- 改用 Ctrl+u 替代 K，避免与 LSP hover 冲突
keymap("n", "H", "0")
keymap("n", "L", "$")
keymap("n", "<M-o>", "o<Esc>")
keymap("n", "<leader>k", ":FloatermKill<CR>")
keymap("n", "j", "gj")
keymap("n", "k", "gk")
if vim.g.use_native_lsp then
	keymap("n", "<leader>=", function()
		vim.lsp.buf.format({ async = true })
	end, { desc = "格式化代码 (Native LSP)" })
else
	keymap("n", "<leader>=", ":call CocActionAsync('format')<CR>", { desc = "格式化代码 (COC)" })
end

-- 可视模式映射
keymap("v", "<C-j>", ":m '>+1<CR>gv=gv")
keymap("v", "<C-k>", ":m '<-2<CR>gv=gv")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")
keymap("v", "L", "$")
keymap("v", "J", "15j")
keymap("v", "<C-u>", "15k") -- 保持一致，改用 Ctrl+u
keymap("v", "H", "0")
keymap("v", "L", "$")

-- 插入模式映射
keymap("i", "jk", "<esc>")
keymap("i", "<c-}>", "<Plug>(copilot-prev)")
keymap("i", "<c-]>", "<Plug>(copilot-next)")
keymap("i", "<F5>", "<esc><F5>")
keymap("i", "<leader>a", "<esc>A")
keymap("i", "<leader>i", "<esc>I")
keymap("i", ",", ",<c-g>u")
keymap("i", ".", ".<c-g>u")
if vim.g.mapleader ~= ";" then
	keymap("i", ";", ";<c-g>u")
end
keymap("i", "<C-o>", "<Esc>o")

-- quickfix
keymap("n", "<leader>cf", vim.lsp.buf.code_action, { desc = "quick fix" })
-- asyncrun.vim
-- keymap("n", "<F5>", ":AsyncTasks<CR>")

local fzf_lua = require("fzf-lua")

vim.keymap.set("n", "\\t", function()
	local rows = vim.fn["asynctasks#source"](math.floor(vim.go.columns * 0.48)) or {}

	if #rows == 0 then
		print("No tasks found.")
		return
	end

	fzf_lua.fzf_exec(
		vim.tbl_map(function(e)
			local color = fzf_lua.utils.ansi_codes
			return color.green(e[1]) .. " " .. color.cyan(e[2]) .. ": " .. color.yellow(e[3])
		end, rows),
		{
			actions = {
				["default"] = function(selected)
					local str = vim.split(selected[1], " ")
					local command = "AsyncTask " .. vim.fn.fnameescape(str[1])
					vim.cmd(command)
				end,
			},
			fzf_opts = {
				["--no-multi"] = "",
				["--nth"] = "1",
			},
			winopts = {
				height = 0.6,
				width = 0.6,
			},
		}
	)
end, { noremap = true, silent = true })

-- floaterm

-- 搜索增强键位映射
keymap("n", "/", function()
	-- 启用搜索时的补全功能
	return "/"
end, { expr = true, desc = "搜索 (带补全)" })

keymap("n", "?", function()
	-- 启用反向搜索时的补全功能
	return "?"
end, { expr = true, desc = "反向搜索 (带补全)" })

-- 快速搜索当前单词
keymap("n", "*", "*zz", { desc = "搜索当前单词并居中" })
keymap("n", "#", "#zz", { desc = "反向搜索当前单词并居中" })

-- 搜索结果跳转
keymap("n", "n", "nzzzv", { desc = "下一个搜索结果并居中" })
keymap("n", "N", "Nzzzv", { desc = "上一个搜索结果并居中" })

-- 清除搜索高亮
-- keymap("n", "<Esc>", ":nohlsearch<CR>", { desc = "清除搜索高亮" })

-- 搜索替换增强键位映射
keymap("n", "<leader>ss", ":%s/", { desc = "全局搜索替换 (带补全)" })
keymap("n", "<leader>sl", ":s/", { desc = "当前行搜索替换 (带补全)" })
keymap("c", "<C-V>", "<C-r>+", {desc = "粘贴"})
-- 可视模式下的搜索替换
keymap("v", "<leader>ss", ":s/", { desc = "选中区域搜索替换 (带补全)" })

-- 快速替换当前单词
keymap("n", "<leader>sr", function()
	local current_word = vim.fn.expand("<cword>")
	if current_word ~= "" then
		return ":%s/\\<" .. current_word .. "\\>/"
	else
		return ":%s/"
	end
end, { expr = true, desc = "替换当前单词 (带补全)" })

-- 快速替换可视选择的文本
keymap("v", "<leader>sr", function()
	-- 获取选中的文本
	vim.cmd('normal! "vy')
	local selected_text = vim.fn.getreg('v')
	-- 转义特殊字符
	selected_text = vim.fn.escape(selected_text, '/\\')
	return ":s/" .. selected_text .. "/"
end, { expr = true, desc = "替换选中文本 (带补全)" })

-- 数据库相关键位映射 (这些会被 database.lua 插件覆盖，但提供默认映射)
keymap("n", "<leader>db", ":echo '数据库插件未加载'<CR>", { desc = "数据库UI (需要插件)" })

