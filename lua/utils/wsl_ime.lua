local M = {}

function M.setup()
	local function mspy_exe_path()
		-- 1. 允许用户通过全局变量覆盖
		if vim.g.ime_mspy_path and vim.g.ime_mspy_path ~= "" then
			return vim.g.ime_mspy_path
		end

		local candidates = {}

		-- 2. 获取 Windows 的 LOCALAPPDATA 路径
		local win_local_appdata = nil
		if vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
			win_local_appdata = vim.env.LOCALAPPDATA
		elseif vim.fn.has("wsl") == 1 then
			-- 在 WSL 中通过 cmd.exe 获取
			local path = vim.fn.system("cmd.exe /c echo %LOCALAPPDATA%")
			if vim.v.shell_error == 0 then
				win_local_appdata = path:gsub("%s+", "") -- 去除空白字符
			end
		end

		-- 3. 根据环境构建路径
		if win_local_appdata and win_local_appdata ~= "" then
			local im_select_subpath = "\\nvim-data\\im-select-mspy\\im-select-mspy.exe"
			
			if vim.fn.has("wsl") == 1 then
				-- 将 Windows 路径转换为 WSL 路径
				local win_full_path = win_local_appdata .. im_select_subpath
				local wsl_path = vim.fn.system({ "wslpath", "-u", win_full_path })
				if vim.v.shell_error == 0 then
					wsl_path = wsl_path:gsub("%s+", "")
					table.insert(candidates, wsl_path)
				end
			else
				-- Windows 环境
				table.insert(candidates, win_local_appdata .. im_select_subpath)
			end
		end

		-- 4. 标准 Neovim 数据目录 (Linux/WSL 原生路径 或 Windows 数据目录)
		local data_dir = vim.fn.stdpath("data")
		table.insert(candidates, data_dir .. "/im-select-mspy/im-select-mspy.exe")

		-- 5. 检查哪个路径存在
		for _, candidate in ipairs(candidates) do
			if candidate and candidate ~= "" and vim.fn.filereadable(candidate) == 1 then
				return candidate
			end
		end

		return candidates[1] -- 默认返回第一个
	end

	local cached_path = nil

	local function get_executable()
		if cached_path ~= nil then
			return cached_path
		end

		local path = mspy_exe_path()
		if path and path ~= "" and vim.fn.executable(path) == 1 then
			cached_path = path
			return cached_path
		end

		cached_path = false
		return cached_path
	end

	vim.api.nvim_create_autocmd({ "InsertLeave", "WinEnter", "FocusGained" }, {
		group = vim.api.nvim_create_augroup("WSL_IME_Switch", { clear = true }),
		callback = function()
			local exe = get_executable()
			if not exe then
				return
			end
			
			-- 调用 im-select-mspy 切换到英文模式
			vim.fn.system({ exe, "-k=ctrl+space", "英语模式" })
		end,
	})
end

return M