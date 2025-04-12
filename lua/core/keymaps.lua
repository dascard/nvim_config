local keymap = vim.keymap.set

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
keymap("n", "K", "15k")
keymap("n", "H", "0")
keymap("n", "L", "$")
keymap("n", "<M-o>", "o<Esc>")
keymap("n", "<leader>k", ":FloatermKill<CR>")
keymap("n", "j", "gj")
keymap("n", "k", "gk")
--keymap("n", "<leader>=", "gg=G")

-- 可视模式映射
keymap("v", "<C-j>", ":m '>+1<CR>gv=gv")
keymap("v", "<C-k>", ":m '<-2<CR>gv=gv")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")
keymap("v", "L", "$")
keymap("v", "J", "15j")
keymap("v", "K", "15k")
keymap("v", "H", "0")
keymap("v", "L", "$")

-- 插入模式映射
keymap("i", "jk", "<esc>")
keymap("i", "<c-}>", "<Plug>(copilot-prev)")
keymap("i", "<c-]>", "<Plug>(copilot-next)")
keymap("i", "<F5>", "<esc><F5>")
keymap("i", "<leader>a", "<esc>A")
keymap("i", ",", ",<c-g>u")
keymap("i", ".", ".<c-g>u")
keymap("i", ";", ";<c-g>u")
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
