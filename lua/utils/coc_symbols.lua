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

local function list_clients(bufnr)
	if bufnr ~= nil then
		return get_clients({ bufnr = bufnr })
	end
	return get_clients()
end

local function has_document_provider(bufnr)
	for _, client in ipairs(list_clients(bufnr)) do
		if client then
			local caps = client.server_capabilities or client.resolved_capabilities or {}
			local supports = (client.supports_method and client:supports_method("textDocument/documentSymbol", { bufnr = bufnr }))
			if supports or caps.documentSymbolProvider then
				return true
			end
		end
	end
	return false
end

local function has_workspace_provider()
	for _, client in ipairs(list_clients()) do
		if client then
			local caps = client.server_capabilities or client.resolved_capabilities or {}
			local supports = (client.supports_method and client:supports_method("workspace/symbol"))
			if supports or caps.workspaceSymbolProvider then
				return true
			end
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

local function normalize_result(result)
	if result == nil or result == VIM_NIL then
		return {}
	end
	if type(result) ~= "table" then
		return {}
	end
	return result
end

local function call_coc_action(action, ...)
	if vim.fn.exists("*CocAction") ~= 1 then
		return nil, "CocAction not available"
	end
	if not is_coc_ready() then
		return nil, "coc.nvim not ready"
	end
	local ok, result = pcall(vim.fn.CocAction, action, ...)
	if not ok then
		return nil, result
	end
	return result, nil
end

local function document_ctx(bufnr)
	return {
		method = "textDocument/documentSymbol",
		bufnr = bufnr,
		client_id = nil,
	}
end

local function workspace_ctx()
	return {
		method = "workspace/symbol",
	}
end

local function handle_document_symbols(bufnr, handler, fallback, attempt)
	attempt = attempt or 1
	handler = handler or vim.lsp.handlers["textDocument/documentSymbol"]
	local result, err = call_coc_action("documentSymbols")
	if err and type(err) == "string" and err:lower():find("not ready", 1, true) and attempt < 5 then
		defer_retry(function()
			handle_document_symbols(bufnr, handler, fallback, attempt + 1)
		end, 150 * attempt)
		return -1
	end
	if err and fallback then
		local ok, handled = pcall(fallback, err)
		if ok and handled ~= nil then
			return handled
		end
	end
	schedule_handler(handler, normalize_error(err), normalize_result(result), document_ctx(bufnr))
	return -1
end

local function handle_workspace_symbols(query, handler, fallback, attempt)
	attempt = attempt or 1
	handler = handler or vim.lsp.handlers["workspace/symbol"]
	local result, err = call_coc_action("workspaceSymbols", query or "")
	if err and type(err) == "string" and err:lower():find("not ready", 1, true) and attempt < 5 then
		defer_retry(function()
			handle_workspace_symbols(query, handler, fallback, attempt + 1)
		end, 150 * attempt)
		return -1
	end
	if err and fallback then
		local ok, handled = pcall(fallback, err)
		if ok and handled ~= nil then
			return handled
		end
	end
	schedule_handler(handler, normalize_error(err), normalize_result(result), workspace_ctx())
	return -1
end

local function supports_method(method, bufnr)
	for _, client in ipairs(list_clients(bufnr)) do
		if client then
			if client.supports_method and client:supports_method(method, { bufnr = bufnr }) then
				return true
			end
			local caps = client.server_capabilities or client.resolved_capabilities or {}
			if method == "textDocument/documentSymbol" and caps.documentSymbolProvider then
				return true
			end
			if method == "workspace/symbol" and caps.workspaceSymbolProvider then
				return true
			end
		end
	end
	return false
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
	local original_buf_request = vim.lsp.buf_request
	local original_buf_request_all = vim.lsp.buf_request_all

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

		local fallback = function()
			if original_document_symbol then
				return original_document_symbol(cb_params, handler)
			end
			return nil
		end

		return handle_document_symbols(bufnr, handler, fallback)
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

		local fallback = function()
			if original_workspace_symbol then
				return original_workspace_symbol(actual_query, handler)
			end
			return nil
		end

		return handle_workspace_symbols(actual_query, handler, fallback)
	end

	vim.lsp.buf_request = function(bufnr, method, params, handler)
		local original = original_buf_request
		local request_id = nil
		if original then
			request_id = original(bufnr, method, params, handler)
		end
		if request_id ~= nil then
			return request_id
		end

		if method == "textDocument/documentSymbol" and not supports_method(method, bufnr) then
			return handle_document_symbols(bufnr or vim.api.nvim_get_current_buf(), handler, nil)
		end

		if method == "workspace/symbol" and not has_workspace_provider() then
			local query = ""
			if type(params) == "table" then
				query = params.query or query
			elseif type(params) == "string" then
				query = params
			end
			return handle_workspace_symbols(query, handler, nil)
		end

		return request_id
	end

	vim.lsp.buf_request_all = function(bufnr, method, params)
		local original = original_buf_request_all
		local clients = list_clients(bufnr)
		local has_clients = false
		for _, _ in ipairs(clients) do
			has_clients = true
			break
		end

		if original and has_clients then
			return original(bufnr, method, params)
		end

		if method == "workspace/symbol" and not has_workspace_provider() then
			local query = ""
			if type(params) == "table" then
				query = params.query or query
			elseif type(params) == "string" then
				query = params
			end
			local result, err = call_coc_action("workspaceSymbols", query or "")
			return {
				coc = {
					result = normalize_result(result),
					error = normalize_error(err),
				},
			}
		end

		if method == "textDocument/documentSymbol" and not supports_method(method, bufnr) then
			local result, err = call_coc_action("documentSymbols")
			return {
				coc = {
					result = normalize_result(result),
					error = normalize_error(err),
				},
			}
		end

		if original then
			return original(bufnr, method, params)
		end

		return {}
	end

	return true
end

return M
