vim.opt.rtp:append("/home/dascard/.local/share/nvim/lazy/nvim-lspconfig")
require("lspconfig")
local mt = getmetatable(vim.lsp.config)
if mt and mt.__call then
  print("vim.lsp.config is callable")
else
  print("vim.lsp.config is NOT callable")
end
