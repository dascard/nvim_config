local M = {}

local ts = vim.treesitter

local function ensure_highlights()
	local definitions = {
		MiniMapTSFunction = "Function",
		MiniMapTSMethod = "Function",
		MiniMapTSClass = "Type",
		MiniMapTSInterface = "Type",
		MiniMapTSStruct = "Structure",
		MiniMapTSEnum = "Type",
		MiniMapTSNamespace = "Identifier",
	}

	for name, target in pairs(definitions) do
		vim.api.nvim_set_hl(0, name, { link = target, default = true })
	end
end

local important_nodes = {
	function_definition = "MiniMapTSFunction",
	function_declaration = "MiniMapTSFunction",
	method_definition = "MiniMapTSMethod",
	method_declaration = "MiniMapTSMethod",
	method = "MiniMapTSMethod",
	class_definition = "MiniMapTSClass",
	class_declaration = "MiniMapTSClass",
	class_specification = "MiniMapTSClass",
	interface_declaration = "MiniMapTSInterface",
	interface_definition = "MiniMapTSInterface",
	struct_specifier = "MiniMapTSStruct",
	struct_declaration = "MiniMapTSStruct",
	enum_specifier = "MiniMapTSEnum",
	enum_declaration = "MiniMapTSEnum",
	namespace_definition = "MiniMapTSNamespace",
	module_declaration = "MiniMapTSNamespace",
}

local function collect_nodes(bufnr)
	if not ts or not ts.get_parser then
		return {}
	end

	local ok, parser = pcall(ts.get_parser, bufnr)
	if not ok or not parser then
		return {}
	end

	local highlights = {}
	local seen = {}

	local function track(node)
		local hl = important_nodes[node:type()]
		if hl then
			local start_row = node:range()
			local line = start_row + 1
			if line > 0 then
				local key = line .. ":" .. hl
				if not seen[key] then
					seen[key] = true
					table.insert(highlights, { line = line, hl_group = hl })
				end
			end
		end

		for child in node:iter_children() do
			track(child)
		end
	end

	parser:for_each_tree(function(tree)
		local root = tree:root()
		if root then
			track(root)
		end
	end)

	table.sort(highlights, function(a, b)
		if a.line == b.line then
			return a.hl_group < b.hl_group
		end
		return a.line < b.line
	end)

	return highlights
end
function M.is_available()
	return ts ~= nil and ts.get_parser ~= nil
end

function M.minimap_integration(map_module)
	if not M.is_available() or not map_module then
		return nil
	end

	ensure_highlights()

	return function()
		local current = rawget(map_module, "current")
		local bufnr = current and current.buf_data and current.buf_data.source
		if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
			return {}
		end

		return collect_nodes(bufnr)
	end
end

function M.collect(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	return collect_nodes(bufnr)
end

return M
