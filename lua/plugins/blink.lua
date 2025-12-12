return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    -- Avante 补全源
    {
      "Kaiser-Yang/blink-cmp-avante",
      -- 仅在 avante 启用时加载
      cond = function()
        return pcall(require, "avante")
      end,
    },
  },
  version = 'v0.*',
  
  -- 不使用 enabled，让 lazy.nvim 可以按需加载
  lazy = true,
  event = vim.g.use_native_lsp and { "InsertEnter", "CmdlineEnter" } or {},

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 动态检查是否启用
    enabled = function()
      return vim.g.use_native_lsp == true
    end,

    keymap = {
      preset = 'default',
      -- 类似 COC 的按键习惯
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide' },
      ['<CR>'] = { 'accept', 'fallback' },
      
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then return cmp.accept() end
          if cmp.is_visible() then return cmp.select_next() end
        end,
        'snippet_forward',
        function(cmp)
          -- 使用 feedkeys 强制发送 Tab 键，并使用 'n' 标志避免递归映射
          -- 这可以绕过任何可能导致 <t_ü> 的错误映射
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, true, true), "n", true)
        end
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.is_visible() then return cmp.select_prev() end
        end,
        'snippet_backward',
        'fallback'
      },
      ['<Up>'] = { 'select_prev', 'fallback' },
      ['<Down>'] = { 'select_next', 'fallback' },
    },

    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
      kind_icons = {
        Text = '󰉿',
        Method = '󰆧',
        Function = '󰊕',
        Constructor = '',
        Field = '󰜢',
        Variable = '󰀫',
        Class = '󰠱',
        Interface = '',
        Module = '',
        Property = '󰜢',
        Unit = '󰑭',
        Value = '󰎠',
        Enum = '',
        Keyword = '󰌋',
        Snippet = '',
        Color = '󰏘',
        File = '󰈙',
        Reference = '󰈇',
        Folder = '󰉋',
        EnumMember = '',
        Constant = '󰏷',
        Struct = '󰙅',
        Event = '',
        Operator = '󰆕',
        TypeParameter = '󰅲',
      },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'avante' },
      providers = {
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {},
        },
      },
    },

    -- 签名帮助
    signature = { 
      enabled = true,
      window = {
        border = 'rounded',
        winblend = 10,
      },
    },
    
    -- 补全文档
    completion = {
        menu = {
            border = 'rounded',
            winblend = 10, -- 降低透明度以增加对比度
        },
        documentation = {
            window = {
                border = 'rounded',
                winblend = 10, -- 降低透明度以增加对比度
            },
            auto_show = true,
            auto_show_delay_ms = 200,
        },
        ghost_text = {
            enabled = true,
        },
    },
  },
  opts_extend = { "sources.default" }
}
