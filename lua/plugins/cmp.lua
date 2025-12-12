local kind_icons = {
	Text = "󰉿", -- 文本
	Method = "󰆧", -- 方法
	Function = "󰊕", -- 函数
	Constructor = "", -- 构造器
	Field = "󰜢", -- 字段
	Variable = "󰀫", -- 变量
	Class = "󰠱", -- 类
	Interface = "", -- 接口
	Module = "", -- 模块
	Property = "󰜢", -- 属性
	Unit = "󰑭", -- 单位
	Value = "󰎠", -- 值
	Enum = "", -- 枚举
	Keyword = "󰌋", -- 关键字
	Snippet = "", -- 片段
	Color = "󰏘", -- 颜色
	File = "󰈙", -- 文件
	Reference = "󰈇", -- 引用
	Folder = "󰉋", -- 文件夹
	EnumMember = "", -- 枚举成员
	Constant = "󰏷", -- 常量
	Struct = "󰙅", -- 结构体
	Event = "", -- 事件
	Operator = "󰆕", -- 运算符
	TypeParameter = "󰅲", -- 类型参数
	Copilot = "",
}
-- CMP 配置 - 针对 COC.nvim 优化
return {
	"hrsh7th/nvim-cmp",
	enabled = false, -- 已被 blink.cmp 替代
	event = "InsertEnter",
	dependencies = {
		"hrsh7th/cmp-buffer", -- source for text in buffer
		"hrsh7th/cmp-path", -- source for file system paths
		"hrsh7th/cmp-cmdline", -- source for command line
		{
			"L3MON4D3/LuaSnip",
			-- follow latest release.
			version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
			-- install jsregexp (optional!).
			build = "make install_jsregexp",
		},
		"saadparwaiz1/cmp_luasnip", -- for autocompletion
		"rafamadriz/friendly-snippets", -- useful snippets
		"onsails/lspkind.nvim", -- vs-code like pictograms
		"kristijanhusak/vim-dadbod-completion", -- database completion
	},
	config = function()
		local cmp = require("cmp")

		local luasnip = require("luasnip")

		local lspkind = require("lspkind")

		-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
		require("luasnip.loaders.from_vscode").lazy_load()

		cmp.setup({
			window = {
				completion = cmp.config.window.bordered({
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					winblend = 0,
				}),
				documentation = cmp.config.window.bordered({
					winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
					winblend = 0,
				}),
			},
			preselect = cmp.PreselectMode.Item,
			completion = {
				completeopt = "menu,menuone,preview,noselect,noinsert",
			},
			snippet = { -- configure how nvim-cmp interacts with snippet engine
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			mapping = cmp.mapping.preset.insert({
				["<C-k>"] = cmp.mapping.select_prev_item(), -- previous suggestion
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
				["<C-e>"] = cmp.mapping.abort(), -- close completion window
				["<CR>"] = cmp.mapping.confirm({ select = true }),
				["<Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif require("copilot.suggestion").is_visible() then
						require("copilot.suggestion").accept()
					elseif luasnip.expandable() then
						luasnip.expand()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<S-Tab>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
				["<M-j>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif require("copilot.suggestion").is_visible() then
						require("copilot.suggestion").accept()
					elseif luasnip.expandable() then
						luasnip.expand()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, {
					"i",
					"s",
				}),
				["<M-k>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, {
					"i",
					"s",
				}),
			}),
			-- sources for autocompletion
			formatting = {
				fields = { "kind", "abbr", "menu" },
				format = function(entry, vim_item)
					-- Kind icons
					vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
					-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
					vim_item.menu = ({
						nvim_lsp = "[LSP]",
						luasnip = "[Snippet]",
						buffer = "[Buffer]",
						path = "[Path]",
						copilot = "[Copilot]",
						cmdline = "[Cmdline]",
						["vim-dadbod-completion"] = "[DB]",
					})[entry.source.name]
					return vim_item
				end,
			},
			sources = {
				{ name = "render-markdown" },
				{ name = "copilot", priority = 100 },
				{ name = "nvim_lsp", priority = 95 },
				{ name = "luasnip", priority = 90 },
				{ name = "buffer" },
				{ name = "path" },
				{ name = "vim-dadbod-completion" },
			},
		})
	end,
}
