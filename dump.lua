local ok, map = pcall(require, 'mini.map')
if not ok then
  return
end
local path = vim.api.nvim_get_runtime_file('lua/mini/map.lua', false)[1]
if not path then
  return
end
local data = vim.fn.readfile(path)
vim.fn.writefile(data, 'mini_map_runtime.lua')
