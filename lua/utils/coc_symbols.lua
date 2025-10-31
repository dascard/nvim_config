local M = {}

local VIM_NIL = rawget(vim, "NIL")

local function get_clients(opts)
	if vim.lsp and vim.lsp.get_clients then
		return vim.lsp.get_clients(opts)
	end
	if vim.lsp and vim.lsp.get_active_clients then
		return vim.lsp.get_active_clients(opts)
	end
	return {}
end

local function is_coc_ready()
	local ok_exists, has_ready = pcall(vim.fn.exists, "*coc#rpc#ready")
	if not ok_exists or has_ready ~= 1 then
		return false
	end

	local ok_ready, ready = pcall(vim.fn["coc#rpc#ready"])
	return ok_ready and ready == 1
end

local function defer_retry(fn, delay)
	local delay_ms = delay or 200
	if vim.defer_fn then
		vim.defer_fn(fn, delay_ms)
	elseif vim.schedule then
		vim.schedule(fn)
	else
		fn()
	end
end

local function has_document_provider(bufnr)
	for _, client in ipairs(get_clients({ bufnr = bufnr })) do
		local caps = client.server_capabilities or client.resolved_capabilities
		if caps and caps.documentSymbolProvider then
			return true
		end
	end
	return false
end

local function has_workspace_provider()
	for _, client in ipairs(get_clients()) do
		local caps = client.server_capabilities or client.resolved_capabilities
		if caps and caps.workspaceSymbolProvider then
			return true
		end
	end
	return false
end

local function schedule_handler(handler, err, result, ctx)
	if not handler then
		return
	end
	local function exec()
		handler(err, result, ctx)
	end
	if vim.schedule then
		vim.schedule(exec)
	else
		exec()
	end
end

local function normalize_error(err)
	if err == nil or err == 0 or err == VIM_NIL then
		return nil
	end
	return err
end


function M.setup()
	if type(vim.fn.CocActionAsync) ~= "function" then
		return
	end

	if not vim.lsp then
		vim.lsp = {}
	end

	if not vim.lsp.buf then
		vim.lsp.buf = {}
	end

	if M._enabled then
		return
	end

	M._enabled = true

	local original_document_symbol = vim.lsp.buf.document_symbol
	local original_workspace_symbol = vim.lsp.buf.workspace_symbol

	vim.lsp.buf.document_symbol = function(params, handler)
		local bufnr = vim.api.nvim_get_current_buf()
		local cb_params = params

		if type(params) == "number" then
			bufnr = params
			cb_params = nil
		elseif type(params) == "table" then
			if params.bufnr then
				bufnr = params.bufnr
			end
		else
			handler = params
			cb_params = nil
		end

		handler = handler or vim.lsp.handlers["textDocument/documentSymbol"]

		if has_document_provider(bufnr) and original_document_symbol then
			return original_document_symbol(cb_params, handler)
		end

		local attempts = 0

		local function request()
			attempts = attempts + 1

			if not is_coc_ready() then
				if attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				if original_document_symbol then
					return original_document_symbol(cb_params, handler)
				end
				return schedule_handler(handler, "coc.nvim not ready", {}, {
					method = "textDocument/documentSymbol",
					bufnr = bufnr,
				})
			end

			local function on_result(err, result)
				if type(err) == "string" and err:lower():find("not ready", 1, true) and attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				local ctx = {
					method = "textDocument/documentSymbol",
					bufnr = bufnr,
					client_id = nil,
				}
				schedule_handler(handler, normalize_error(err), result or {}, ctx)
			end

			local ok = pcall(vim.fn.CocActionAsync, "documentSymbols", function(err, res)
				on_result(err, res)
			end)

			if not ok then
				if attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				if original_document_symbol then
					return original_document_symbol(cb_params, handler)
				end
			end
		end

		return request()
	end

	vim.lsp.buf.workspace_symbol = function(query, handler)
		handler = handler or vim.lsp.handlers["workspace/symbol"]

		if has_workspace_provider() and original_workspace_symbol then
			return original_workspace_symbol(query, handler)
		end

		local actual_query = ""
		if type(query) == "string" then
			actual_query = query
		elseif type(query) == "table" then
			actual_query = query.query or query[1] or ""
		else
			handler = query
		end

		if type(handler) ~= "function" then
			handler = vim.lsp.handlers["workspace/symbol"]
		end

		local attempts = 0

		local function request()
			attempts = attempts + 1

			if not is_coc_ready() then
				if attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				if original_workspace_symbol then
					return original_workspace_symbol(actual_query, handler)
				end
				return schedule_handler(handler, "coc.nvim not ready", {}, {
					method = "workspace/symbol",
				})
			end

			local function on_result(err, result)
				if type(err) == "string" and err:lower():find("not ready", 1, true) and attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				local ctx = {
					method = "workspace/symbol",
				}
				schedule_handler(handler, normalize_error(err), result or {}, ctx)
			end

			local ok = pcall(vim.fn.CocActionAsync, "workspaceSymbols", actual_query or "", function(err, res)
				on_result(err, res)
			end)

			if not ok then
				if attempts < 5 then
					defer_retry(request, 150 * attempts)
					return
				end
				if original_workspace_symbol then
					return original_workspace_symbol(actual_query, handler)
				end
			end
		end

		return request()
	end

	return true
end

return M
