-- search_completion.lua
--
-- Enhanced version with wildmenu-style completion and live preview
-- Uses native command-line completion for better UX

local M = {}

math.randomseed(vim.loop.hrtime())

local is_vscode = vim.g ~= nil and vim.g.vscode ~= nil

local state = {
	is_active = false,
	original_term = '',
	matches = {},
	current_index = 0,
	term_start_col = -1,
	last_completion = nil,
	-- Preview state
	preview_mark = nil,
	original_cursor = nil,
	-- Floating window state
	float_win = nil,
	float_buf = nil,
	-- Scroll state
	scroll_offset = 0,
	max_display_items = 15,
	-- Search state
	is_partial_search = false,
	-- Index caches
	index_tick = 0,
	index_buf = nil,
	symbol_index = nil,
	word_index = nil,
	partial_samples = nil,
	-- VSCode picker tracking
	vscode_picker_open = false,
}

local function reset_state()
	-- Clear preview mark
	if state.preview_mark then
		pcall(vim.api.nvim_buf_del_extmark, 0, vim.api.nvim_create_namespace('search_complete_preview'), state.preview_mark)
	end
	-- Restore cursor if needed
	if state.original_cursor then
		pcall(vim.api.nvim_win_set_cursor, 0, state.original_cursor)
	end
	-- Close floating window if exists
	if state.float_win and vim.api.nvim_win_is_valid(state.float_win) then
		vim.api.nvim_win_close(state.float_win, true)
	end
	if state.float_buf and vim.api.nvim_buf_is_valid(state.float_buf) then
		vim.api.nvim_buf_delete(state.float_buf, { force = true })
	end

	state.is_active = false
	state.original_term = ''
	state.matches = {}
	state.current_index = 0
	state.term_start_col = -1
	state.last_completion = nil
	state.preview_mark = nil
	state.original_cursor = nil
	state.float_win = nil
	state.float_buf = nil
	state.scroll_offset = 0
	state.is_partial_search = false
	state.vscode_picker_open = false
end

local function should_ignore_case(term)
	if not vim.o.ignorecase then
		return false
	end
	if vim.o.smartcase and term:find('[A-Z]') then
		return false
	end
	return true
end

local function escape_literal(term)
	-- In very nomagic mode, only newlines and backslashes are special
	return term:gsub('\\', '\\\\'):gsub('\n', '\\n')
end

local function extend_match_text(line, start_idx0, base_text)
	local term_len = #base_text
	local start_col = start_idx0 + 1
	local end_idx = start_idx0 + term_len
	local line_len = #line

	while end_idx < line_len do
		local ch = line:sub(end_idx + 1, end_idx + 1)
		if ch:match('[%w_]') then
			end_idx = end_idx + 1
		else
			break
		end
	end

	return line:sub(start_col, end_idx), start_col
end

local identifier_types = {
	identifier = true,
	field_identifier = true,
	property_identifier = true,
	type_identifier = true,
	method_identifier = true,
	attribute = true,
	enum_member_identifier = true,
}

local function collect_treesitter_symbols(buf)
	local ok, parser = pcall(vim.treesitter.get_parser, buf)
	if not ok then
		return {}
	end
	local seen = {}
	local symbols = {}
	parser:for_each_tree(function(tree)
		local root = tree:root()
		if not root then
			return
		end
		local function visit(node)
			local node_type = node:type()
			if identifier_types[node_type] then
				local text = vim.treesitter.get_node_text(node, buf)
				if text and text:match('%S') and not seen[text] then
					seen[text] = true
					local row, col = node:range()
					table.insert(symbols, { word = text, pos = { row + 1, col + 1 }, source = 'treesitter' })
				end
			end
			for child in node:iter_children() do
				visit(child)
			end
		end
		visit(root)
	end)
	return symbols
end

local function flatten_lsp_symbols(list, acc)
	for _, item in ipairs(list or {}) do
		if item.name and item.selectionRange then
			local sr = item.selectionRange
			local pos = { (sr.start.line or 0) + 1, (sr.start.character or 0) + 1 }
			table.insert(acc, { word = item.name, pos = pos, kind = item.kind, source = 'lsp' })
		end
		if item.children then
			flatten_lsp_symbols(item.children, acc)
		end
	end
end

local function collect_lsp_symbols(buf)
	local supported = false
	for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = buf })) do
		if client.supports_method and client:supports_method('textDocument/documentSymbol') then
			supported = true
			break
		end
	end
	if not supported then
		return {}
	end
	local params = { textDocument = vim.lsp.util.make_text_document_params(buf) }
	local results = {}
	local responses = vim.lsp.buf_request_sync(buf, 'textDocument/documentSymbol', params, 250)
	if not responses then
		return results
	end
	for _, resp in pairs(responses) do
		if resp and resp.result then
			flatten_lsp_symbols(resp.result, results)
		end
	end
	local seen = {}
	local unique = {}
	for _, item in ipairs(results) do
		if item.word and item.word:match('%S') and not seen[item.word] then
			seen[item.word] = true
			table.insert(unique, item)
		end
	end
	return unique
end

local function build_sampling_ranges(line_count)
	local ranges = {}
	local visible_start = vim.fn.line('w0')
	local visible_end = vim.fn.line('w$')
	local visible_pad = 200
	local v_start = math.max(1, visible_start - visible_pad)
	local v_end = math.min(line_count, visible_end + visible_pad)
	table.insert(ranges, { v_start, v_end })

	local chunk_size = 200
	local sample_chunks = 10
	local step = math.max(chunk_size, math.floor(line_count / sample_chunks))
	local pos = 1
	while pos <= line_count do
		local s = pos
		local e = math.min(line_count, pos + chunk_size)
		table.insert(ranges, { s, e })
		pos = pos + step
	end

	for _ = 1, sample_chunks do
		local s = math.random(1, math.max(1, line_count - chunk_size + 1))
		table.insert(ranges, { s, math.min(line_count, s + chunk_size) })
	end

	return ranges
end

local function build_word_index(buf)
	local line_count = vim.api.nvim_buf_line_count(buf)
	local ranges
	if line_count <= 3000 then
		ranges = { { 1, line_count } }
	else
		ranges = build_sampling_ranges(line_count)
	end

	local seen = {}
	local index = {}
	for _, range in ipairs(ranges) do
		local lines = vim.api.nvim_buf_get_lines(buf, range[1] - 1, range[2], false)
		for i, line in ipairs(lines) do
			local offset = range[1] + i - 1
			for start_col, word in line:gmatch('()([%w_][%w_%-%+%./]*)') do
				if not seen[word] then
					seen[word] = true
					table.insert(index, { word = word, pos = { offset, start_col }, source = 'word' })
				end
			end
		end
	end

	return index
end

local function ensure_indices()
	local buf = vim.api.nvim_get_current_buf()
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	if state.index_buf == buf and state.index_tick == tick and state.symbol_index then
		return
	end

	state.index_buf = buf
	state.index_tick = tick

	state.symbol_index = {}
	state.symbol_index.treesitter = collect_treesitter_symbols(buf)
	state.symbol_index.lsp = collect_lsp_symbols(buf)
	state.symbol_index.merged = {}
	for _, list in ipairs({ state.symbol_index.treesitter, state.symbol_index.lsp }) do
		for _, item in ipairs(list) do
			table.insert(state.symbol_index.merged, item)
		end
	end
	state.word_index = build_word_index(buf)
	state.partial_samples = (vim.api.nvim_buf_line_count(buf) > 3000)
end

local function filter_candidates(list, term, ignore_case)
	local matches = {}
	local needle = ignore_case and term:lower() or term
	local seen = {}
	for _, item in ipairs(list or {}) do
		local word = item.word
		if word then
			local hay = ignore_case and word:lower() or word
			if hay:find('^' .. vim.pesc(needle)) then
				if not seen[word] then
					seen[word] = true
					table.insert(matches, item)
				end
			end
		end
	end
	return matches
end

local function extend_with_word_index(matches, term, ignore_case)
	local existing = {}
	for _, item in ipairs(matches) do
		existing[item.word] = true
	end
	local needle = ignore_case and term:lower() or term
	for _, item in ipairs(state.word_index or {}) do
		local word = item.word
		if word and not existing[word] then
			local hay = ignore_case and word:lower() or word
			if hay:find('^' .. vim.pesc(needle)) then
				table.insert(matches, item)
				existing[word] = true
			end
		end
	end
	return matches
end

local scan_literal_matches

local function find_unique_matches(term)
	local ignore_case = should_ignore_case(term)
	local is_phrase = term:find('%s')
	state.is_partial_search = false
	if not is_phrase then
		local stripped = term:gsub('^%s+', ''):gsub('%s+$', '')
		if stripped == '' then
			return {}
		end
		term = stripped
	end

	ensure_indices()

	local matches = {}
	local seen_words = {}
	local used_literal_scan = false
	if not is_phrase then
		local symbol_matches = filter_candidates(state.symbol_index and state.symbol_index.merged or {}, term, ignore_case)
		for _, item in ipairs(symbol_matches) do
			if not seen_words[item.word] then
				seen_words[item.word] = true
				table.insert(matches, item)
			end
		end

		matches = extend_with_word_index(matches, term, ignore_case)
		for _, item in ipairs(matches) do
			seen_words[item.word] = true
		end

		if #matches < 10 then
			used_literal_scan = true
			local additional = scan_literal_matches(term)
			for _, item in ipairs(additional) do
				local word = item.word
				if word and not seen_words[word] then
					seen_words[word] = true
					table.insert(matches, item)
				end
			end
		end
	else
		matches = scan_literal_matches(term)
		used_literal_scan = true
		for _, item in ipairs(matches) do
			seen_words[item.word] = true
		end
	end

	if not used_literal_scan and state.partial_samples and not is_phrase then
		state.is_partial_search = true
	end

	return matches
end

-- The robust, multi-stage, deterministic parser from v11.
local function get_substitute_context()
	local cmdline = vim.fn.getcmdline()
	local cmdpos = vim.fn.getcmdpos()
	if type(cmdline) ~= "string" then return nil end
	local cmd_prefix_end = cmdline:find("s[ubstitute]?")
	if not cmd_prefix_end then return nil end
	local sep = cmdline:sub(cmd_prefix_end + 1, cmd_prefix_end + 1)
	if sep == "" or sep:match("[A-Za-z0-9%s]") then return nil end
	local parts_start, parts, current_part_start, in_escape = cmd_prefix_end + 2, {}, cmd_prefix_end + 2, false
	for i = parts_start, #cmdline do
		local char = cmdline:sub(i, i)
		if char == sep and not in_escape then
			table.insert(parts, { start_col = current_part_start, end_col = i - 1 })
			current_part_start = i + 1
		end
		in_escape = (char == '\\' and not in_escape)
	end
	table.insert(parts, { start_col = current_part_start, end_col = #cmdline })
	local active_part_idx = -1
	for i, part in ipairs(parts) do
		if cmdpos >= part.start_col and cmdpos <= part.end_col + 1 then
			active_part_idx = i; break
		end
	end
	if active_part_idx ~= 1 and active_part_idx ~= 2 then return nil end
	local active_part = parts[active_part_idx]
	local search_term = (parts[1] and #cmdline >= parts[1].end_col) and cmdline:sub(parts[1].start_col, parts[1].end_col) or
			nil
	return {
		term = cmdline:sub(active_part.start_col, active_part.end_col),
		term_start_col = active_part.start_col,
		term_end_col = active_part.end_col,
		is_replace_part = (active_part_idx == 2),
		search_term = search_term,
	}
end

-- De-duplication engine (stable) - Modified to also store positions
-- Performance optimized with smart search strategy
scan_literal_matches = function(term)
	local results, unique, seen = {}, {}, {}
	local cursor = vim.api.nvim_win_get_cursor(0)
	local buf = 0

	if not state.original_cursor then
		state.original_cursor = cursor
	end

	local max_matches = 100
	local line_count = vim.api.nvim_buf_line_count(buf)
	local search_timeout = 100 -- milliseconds
	local start_time = vim.loop.hrtime()

	local use_local_search = line_count > 3000
	local visible_start = vim.fn.line('w0')
	local visible_end = vim.fn.line('w$')
	local context = 300
	local search_ranges = {}
	local scanned_full_buffer = not use_local_search

	if use_local_search then
		local local_start = math.max(1, visible_start - context)
		local local_end = math.min(line_count, visible_end + context)
		table.insert(search_ranges, { local_start, local_end })
		-- Fallback global range will be appended later if time permits
	else
		table.insert(search_ranges, { 1, line_count })
	end

	local ignore_case_prefix = should_ignore_case(term) and '\\c' or ''
	local literal_pattern = ignore_case_prefix .. '\\V' .. escape_literal(term)

	local function collect_from_range(range_start, range_end)
		if #results >= max_matches then
			return true
		end
		local elapsed = (vim.loop.hrtime() - start_time) / 1e6
		if elapsed > search_timeout then
			return true
		end

		local lines = vim.api.nvim_buf_get_lines(buf, range_start - 1, range_end, false)
		for idx, line in ipairs(lines) do
			local search_from = 0
			while true do
				local match = vim.fn.matchstrpos(line, literal_pattern, search_from)
				local matched = match[1]
				local start_idx0 = match[2]
				local end_idx0 = match[3]
				if start_idx0 < 0 then
					break
				end

				local valid = true
				if matched:match('^%w') and start_idx0 > 0 then
					local prev_char = line:sub(start_idx0, start_idx0)
					if prev_char:match('%w') then
						valid = false
					end
				end

				if valid then
					local text, start_col = extend_match_text(line, start_idx0, matched)
					local lnum = range_start + idx - 1
					local pos = { lnum, start_col }
					table.insert(results, { word = text, pos = pos })

					if #results >= max_matches then
						return true
					end
				end

				search_from = math.max(end_idx0, search_from + 1)
			end
		end
	end

	for _, range in ipairs(search_ranges) do
		if collect_from_range(range[1], range[2]) then
			break
		end
	end

	if use_local_search and #results < max_matches then
		local elapsed = (vim.loop.hrtime() - start_time) / 1e6
		if elapsed < search_timeout * 0.6 then
			if collect_from_range(1, line_count) then
				-- nothing else
			end
			scanned_full_buffer = true
		end
	end

	-- Deduplicate preserving order
	for _, item in ipairs(results) do
		if not seen[item.word] then
			seen[item.word] = true
			table.insert(unique, item)
		end
	end

	state.is_partial_search = use_local_search and (not scanned_full_buffer) and #unique > 0

 	return unique
end

-- Create or update scrollable floating window
local function update_float_window()
	if is_vscode then
		return
	end

	if #state.matches == 0 then return end

	-- Prepare all lines (simple format without alignment)
	local all_lines = {}
	for i, match in ipairs(state.matches) do
		local prefix = (i == state.current_index) and "► " or "  "
		table.insert(all_lines, prefix .. match.word)
	end

	-- Add original term
	if state.current_index > #state.matches or state.current_index == 0 then
		table.insert(all_lines, "► " .. state.original_term .. " (original)")
	else
		table.insert(all_lines, "  " .. state.original_term .. " (original)")
	end

	-- Calculate scroll offset to keep current item visible
	if state.current_index > 0 then
		local current_pos = state.current_index > #state.matches and #all_lines or state.current_index
		-- Auto-scroll: keep current item in view
		if current_pos < state.scroll_offset + 1 then
			state.scroll_offset = math.max(0, current_pos - 1)
		elseif current_pos > state.scroll_offset + state.max_display_items then
			state.scroll_offset = current_pos - state.max_display_items
		end
	end

	-- Get visible lines
	local start_idx = state.scroll_offset + 1
	local end_idx = math.min(state.scroll_offset + state.max_display_items, #all_lines)
	local visible_lines = {}
	for i = start_idx, end_idx do
		table.insert(visible_lines, all_lines[i])
	end

	-- Add scroll indicators
	if state.scroll_offset > 0 then
		visible_lines[1] = visible_lines[1] .. " ↑"
	end
	if end_idx < #all_lines then
		visible_lines[#visible_lines] = visible_lines[#visible_lines] .. " ↓"
	end

	-- Create buffer if needed
	if not state.float_buf or not vim.api.nvim_buf_is_valid(state.float_buf) then
		state.float_buf = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_buf_set_option(state.float_buf, 'bufhidden', 'wipe')
		vim.api.nvim_buf_set_option(state.float_buf, 'modifiable', false)
	end

	-- Update buffer content
	vim.api.nvim_buf_set_option(state.float_buf, 'modifiable', true)
	vim.api.nvim_buf_set_lines(state.float_buf, 0, -1, false, visible_lines)
	vim.api.nvim_buf_set_option(state.float_buf, 'modifiable', false)

	-- Calculate window size and position (bottom-right corner)
	local ui = vim.api.nvim_list_uis()[1]

	-- Width: auto-fit content but keep reasonable bounds
	local width = 0
	for _, line in ipairs(visible_lines) do
		width = math.max(width, vim.fn.strdisplaywidth(line))
	end
	width = math.max(width + 4, 35) -- Minimum 35 chars with padding
	width = math.min(width, 60)    -- Maximum 60 chars

	-- Height based on visible items
	local height = math.min(#all_lines, state.max_display_items)

	-- Position: bottom-left corner to avoid cmdline overlap
	local row = ui.height - height - 3 -- 3 lines from bottom (statusline + cmdline + margin)
	local col = 2  -- 2 chars from left edge

	-- Add indicator if search was limited
	local title_suffix = state.is_partial_search and "～" or ""
	
	local opts = {
		relative = 'editor',
		width = width,
		height = height,
		row = row,
		col = col,
		style = 'minimal',
		border = 'rounded',
		title = string.format(' 🔍 %d/%d%s ',
			state.current_index > #state.matches and #state.matches or state.current_index,
			#state.matches,
			title_suffix),
		title_pos = 'center',
		zindex = 150, -- Higher than noice cmdline (100)
	}

	-- Create or update window
	if not state.float_win or not vim.api.nvim_win_is_valid(state.float_win) then
		state.float_win = vim.api.nvim_open_win(state.float_buf, false, opts)
		vim.api.nvim_win_set_option(state.float_win, 'winhl', 'Normal:NormalFloat,FloatBorder:FloatBorder')
		vim.api.nvim_win_set_option(state.float_win, 'winblend', 15) -- 15% 透明度，适中
	else
		vim.api.nvim_win_set_config(state.float_win, opts)
	end

	-- Highlight current selection in visible area
	local ns = vim.api.nvim_create_namespace('search_complete_hl')
	vim.api.nvim_buf_clear_namespace(state.float_buf, ns, 0, -1)

	local current_pos = state.current_index > #state.matches and #all_lines or state.current_index
	local visible_idx = current_pos - state.scroll_offset
	if visible_idx >= 1 and visible_idx <= #visible_lines then
		vim.api.nvim_buf_add_highlight(state.float_buf, ns, 'Visual', visible_idx - 1, 0, -1)
	end
end

-- Preview the match by jumping to it
local function preview_match()
	if is_vscode then
		return
	end

	-- Clear previous preview
	local ns = vim.api.nvim_create_namespace('search_complete_preview')
	vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

	if state.current_index <= 0 or state.current_index > #state.matches then
		-- Restore to original cursor
		if state.original_cursor then
			pcall(vim.api.nvim_win_set_cursor, 0, state.original_cursor)
		end
		return
	end

	local match = state.matches[state.current_index]
	if match and match.pos then
		-- Jump to the match position
		pcall(vim.api.nvim_win_set_cursor, 0, match.pos)

		-- Highlight the match
		local line = match.pos[1] - 1
		local col_start = match.pos[2] - 1
		local col_end = col_start + #match.word

		state.preview_mark = vim.api.nvim_buf_set_extmark(0, ns, line, col_start, {
			end_col = col_end,
			hl_group = 'IncSearch',
			priority = 200,
		})

		-- Position cursor at top to avoid cmdline overlap (not center)
		-- Use API calls instead of normal commands for better performance
		vim.fn.winrestview({ topline = math.max(1, match.pos[1] - 3) })

		-- Show match info as virtual text
		vim.api.nvim_buf_set_extmark(0, ns, line, 0, {
			virt_text = { { string.format("  [%d/%d]", state.current_index, #state.matches), "Comment" } },
			virt_text_pos = "eol",
			priority = 100,
		})
	end
end

local function apply_completion_to_cmdline(word, context)
	if not word then
		return
	end

	local original_cmdline = vim.fn.getcmdline()
	if context then
		local prefix = original_cmdline:sub(1, context.term_start_col - 1)
		local suffix = original_cmdline:sub(context.term_end_col + 1)
		local new_cmdline = prefix .. word .. suffix
		local ok = pcall(vim.fn.setcmdline, new_cmdline)
		if ok then
			pcall(vim.fn.setcmdpos, #prefix + #word + 1)
		end
	else
		pcall(vim.fn.setcmdline, word)
	end
	state.last_completion = word
end

local function show_vscode_picker(context)
	if not is_vscode then
		return false
	end

	if state.vscode_picker_open then
		return true
	end

	state.vscode_picker_open = true

	local items = {}
	for _, match in ipairs(state.matches) do
		local label = match.word or ''
		local detail
		if match.pos then
			detail = string.format('行 %d, 列 %d', match.pos[1], match.pos[2])
		end
		items[#items + 1] = {
			label = label,
			detail = detail,
			match = match,
		}
	end

	if state.original_term ~= '' then
		items[#items + 1] = {
			label = string.format('保留原输入: %s', state.original_term),
			keep_original = true,
		}
	end

	if #items == 0 then
		state.vscode_picker_open = false
		return false
	end

	local prompt_suffix = state.is_partial_search and '（范围有限，继续输入以获取更多结果）' or ''
	local opts = {
		prompt = '搜索补全 ' .. prompt_suffix,
		format_item = function(item)
			if item.keep_original then
				return item.label
			end
			if item.detail and item.detail ~= '' then
				return string.format('%s   →   %s', item.label, item.detail)
			end
			return item.label
		end,
	}

	vim.schedule(function()
		vim.ui.select(items, opts, function(choice)
			state.vscode_picker_open = false
			if not choice then
				reset_state()
				return
			end

			local selected_word = state.original_term
			if not choice.keep_original and choice.match and choice.match.word then
				selected_word = choice.match.word
			end

			vim.schedule(function()
				apply_completion_to_cmdline(selected_word, context)
			end)

			reset_state()
		end)
	end)

	return true
end

-- Core logic with the new "dirty checking" state machine
local function complete(direction)
	local context, cmd_type = nil, vim.fn.getcmdtype()
	local current_term, current_term_start_col

	if cmd_type == ':' then
		context = get_substitute_context()
		if not context then return end
		current_term = context.term
		current_term_start_col = context.term_start_col
	elseif cmd_type == '/' or cmd_type == '?' then
		current_term = vim.fn.getcmdline()
		current_term_start_col = 1
	else
		return
	end

	-- The key condition: Start a new cycle if not active, if the term's location
	-- has changed, OR if the user has manually edited the term.
	if not state.is_active or state.term_start_col ~= current_term_start_col or current_term ~= state.last_completion then
		local term_to_search = current_term
		local intelligent_default = nil
		if context and context.is_replace_part and current_term == "" and context.search_term and context.search_term ~= "" then
			term_to_search = context.search_term
			intelligent_default = term_to_search
		end
		if term_to_search == '' and not intelligent_default then
			reset_state(); return
		end

		state.is_active = true
		state.term_start_col = current_term_start_col
		state.original_term = current_term
		state.matches = find_unique_matches(term_to_search)

		if intelligent_default and not vim.tbl_contains(vim.tbl_map(function(m) return m.word end, state.matches), intelligent_default) then
			table.insert(state.matches, 1, { word = intelligent_default, pos = nil })
		end
		if #state.matches == 0 then
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-g>', true, false, true), 'n', false)
			reset_state(); return
		end
		state.current_index = direction == 'next' and 1 or #state.matches

		if is_vscode then
			if show_vscode_picker(context) then
				return
			end
		end
	else
		if #state.matches == 0 then return end
		if direction == 'next' then
			state.current_index = (state.current_index % (#state.matches + 1)) + 1
		else -- 'prev'
			state.current_index = state.current_index - 1
			if state.current_index < 0 then state.current_index = #state.matches end
		end
	end

	if is_vscode then
		show_vscode_picker(context)
		return
	end

	local word_to_show = (state.current_index > #state.matches or state.current_index == 0) and state.original_term or
			state.matches[state.current_index].word

	apply_completion_to_cmdline(word_to_show, context)

	-- Show completion menu immediately, then reschedule to keep UI in sync
	update_float_window()
	vim.schedule(function()
		update_float_window()
		preview_match()
	end)
end

-- Setup
local augroup = vim.api.nvim_create_augroup('FinalSearchCompleteV12', { clear = true })
vim.api.nvim_create_autocmd('CmdlineEnter', {
	pattern = '[/?:]',
	group = augroup,
	callback = function()
		vim.keymap.set('c', '<C-j>', function() complete('next') end, { buffer = true, nowait = true })
		vim.keymap.set('c', '<C-k>', function() complete('prev') end, { buffer = true, nowait = true })
	end,
})
vim.api.nvim_create_autocmd('CmdlineLeave', {
	pattern = '[/?:]',
	group = augroup,
	callback = function() reset_state() end,
})

return M
