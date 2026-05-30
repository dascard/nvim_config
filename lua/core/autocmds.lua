local function normal_listed_buffer(buf)
	return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "" and vim.bo[buf].buflisted
end

local function replacement_buffer(buf)
	local alt = vim.fn.bufnr("#")
	if alt > 0 and alt ~= buf and normal_listed_buffer(alt) then
		return alt
	end

	for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
		if info.bufnr ~= buf and normal_listed_buffer(info.bufnr) then
			return info.bufnr
		end
	end
end

local function close_last_window(buf, opts)
	opts = opts or {}

	if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified and not opts.force then
		vim.notify("当前是最后一个窗口，且 buffer 未保存；请先保存或使用 :q!。", vim.log.levels.WARN)
		return
	end

	if normal_listed_buffer(buf) then
		local ok, err = pcall(vim.cmd, opts.force and "quit!" or "quit")
		if not ok then
			vim.notify(err, vim.log.levels.WARN)
		end
		return
	end

	local next_buf = replacement_buffer(buf)
	if next_buf then
		vim.api.nvim_set_current_buf(next_buf)
	else
		vim.cmd.enew()
	end

	if vim.api.nvim_buf_is_valid(buf) then
		pcall(vim.api.nvim_buf_delete, buf, { force = opts.force == true })
	end
end

local function safe_close_window(buf, opts)
	opts = opts or {}
	buf = buf or vim.api.nvim_get_current_buf()

	local win = vim.api.nvim_get_current_win()
	local wins = vim.fn.win_findbuf(buf)
	if #wins > 0 and not vim.tbl_contains(wins, win) then
		win = wins[1]
	end

	if vim.fn.winnr("$") > 1 and vim.api.nvim_win_is_valid(win) then
		local ok, err = pcall(vim.api.nvim_win_close, win, opts.force == true)
		if ok then
			return
		end
		if not tostring(err):find("E444", 1, true) then
			vim.notify(err, vim.log.levels.WARN)
			return
		end
	end

	close_last_window(buf, opts)
end

local function safe_close_cmdline(lhs, rhs)
	if vim.fn.getcmdtype() ~= ":" then
		return lhs
	end

	if vim.trim(vim.fn.getcmdline()) == lhs then
		return rhs
	end

	return lhs
end

_G.nvim_safe_close_cmdline = safe_close_cmdline

local function close_command_abbrev(lhs)
	vim.cmd(("cnoreabbrev <expr> %s v:lua.nvim_safe_close_cmdline(%q, 'SafeClose')"):format(lhs, lhs))
end

close_command_abbrev("close")
close_command_abbrev("clos")
close_command_abbrev("clo")

vim.api.nvim_create_user_command("SafeClose", function(command)
	safe_close_window(nil, { force = command.bang })
end, { bang = true })

vim.keymap.set("n", "<C-w>c", safe_close_window, { desc = "Safe close window" })
vim.keymap.set("n", "<C-w><C-c>", safe_close_window, { desc = "Safe close window" })
vim.keymap.set("n", "<C-w>q", safe_close_window, { desc = "Safe quit window" })
vim.keymap.set("n", "<C-w><C-q>", safe_close_window, { desc = "Safe quit window" })

vim.api.nvim_create_autocmd("WinEnter", {
	callback = function()
		if vim.fn.winnr("$") == 1 and vim.bo.buftype == "nofile" then
			safe_close_window(vim.api.nvim_get_current_buf())
		end
	end,
})

local function augroup(name)
	return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				safe_close_window(event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})
