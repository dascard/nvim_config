---@diagnostic disable: missing-fields
-- Minimal config for testing Gemini CLI ACP with CodeCompanion

vim.env.LAZY_STDPATH = ".repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

local plugins = {
  {
    "olimorris/codecompanion.nvim",
    version = "v17.33.0", -- 固定版本
    dependencies = {
      { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      strategies = {
        chat = { adapter = "gemini_cli" },
        inline = { adapter = "gemini_cli" },
      },
      adapters = {
        acp = {
          gemini_cli = function()
            return require("codecompanion.adapters").extend("gemini_cli", {
              commands = {
                default = {
                  "gemini",
                  "--experimental-acp",
                },
              },
              defaults = {
                auth_method = "oauth-personal",
                mcpServers = {},
                timeout = 30000,
              },
            })
          end,
        },
      },
      opts = {
        log_level = "DEBUG",
      },
    },
  },
}

require("lazy.minit").repro({ spec = plugins })

-- Setup Tree-sitter
local ts_status, treesitter = pcall(require, "nvim-treesitter.configs")
if ts_status then
  treesitter.setup({
    ensure_installed = { "lua", "markdown", "markdown_inline", "yaml", "diff" },
    highlight = { enable = true },
  })
end
