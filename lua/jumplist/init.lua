local M = {}

function M.setup()
  local name = 'jumplist'
  local wkp = require('which-key.plugins')
  local plugins = wkp.plugins
  if not plugins[name] then
    plugins[name] = require("jumplist.jumplist")
    wkp._setup(plugins[name], {})
  end
end

return M
