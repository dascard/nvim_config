return {
  'saghen/blink.cmp',
  dependencies = {
    'rafamadriz/friendly-snippets',
    "fang2hou/blink-copilot",
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
  event = vim.g.use_native_lsp and { "InsertEnter" } or {},

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 动态检查是否启用
    enabled = function()
      return vim.g.use_native_lsp == true
    end,

    -- 禁用命令行补全，防止 :! 卡死
    cmdline = {
      enabled = false,
      sources = {}, -- 显式清空来源
    },

    keymap = {
      preset = 'default',
      -- <C-Space> 留给输入法；补全菜单仍由 blink 自动触发。
      ['<C-space>'] = {},
      ['<F2>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = {
        function(cmp)
          local hidden_doc = cmp.hide_documentation()
          local hidden_menu = cmp.hide()
          return hidden_doc or hidden_menu
        end,
        'fallback',
      },
      ['<CR>'] = {
        function(cmp)
          cmp.hide_documentation()
          return cmp.accept()
        end,
        'fallback',
      },
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
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
      default = function()
        local ft = vim.bo.filetype
        if ft == 'Avante' or ft == 'AvanteInput' or ft == 'AvanteSelectedFiles' then
          return { 'copilot', 'avante', 'lsp', 'path', 'snippets', 'buffer' }
        end

        if vim.api.nvim_buf_line_count(0) > 5000 then
          return { 'copilot', 'lsp', 'path', 'snippets' }
        end

        return { 'copilot', 'lsp', 'path', 'snippets', 'buffer' }
      end,
      per_filetype = {
        sql = { 'copilot', 'snippets', 'dadbod', 'buffer' },
        mysql = { 'copilot', 'snippets', 'dadbod', 'buffer' },
        plsql = { 'copilot', 'snippets', 'dadbod', 'buffer' },
      },
      providers = {
        copilot = {
          module = "blink-copilot",
          name = "Copilot",
          async = true,
          score_offset = 100,
          opts = {
            max_completions = 1,
            max_attempts = 2,
          },
        },
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {},
        },
        dadbod = {
          module = "vim_dadbod_completion.blink",
          name = "Dadbod",
        },
        buffer = {
          min_keyword_length = 3,
          max_items = 8,
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
            auto_show_delay_ms = 700,
            update_delay_ms = 100,
        },
        ghost_text = {
            enabled = false,
        },
    },
  },
  config = function(_, opts)
    require("blink.cmp").setup(opts)

    local group = vim.api.nvim_create_augroup("BlinkCmpCleanup", { clear = true })
    vim.api.nvim_create_autocmd({ "TextChangedI", "InsertLeave" }, {
      group = group,
      callback = function()
        local ok, cmp = pcall(require, "blink.cmp")
        if not ok then
          return
        end

        if vim.api.nvim_get_mode().mode ~= "i" then
          cmp.hide_documentation()
          cmp.hide()
          return
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
        if before_cursor == "" or before_cursor:match("%s$") then
          cmp.hide_documentation()
          cmp.hide()
        end
      end,
    })
  end,
}
