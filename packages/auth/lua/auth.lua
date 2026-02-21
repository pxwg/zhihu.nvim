---get cookies.
---all modules under auth must provide a function `get_cookies()`.
---@module auth
local fn = require 'vim.fn'
local M = {
  auths = {
    'auth.firefox',
    'auth.chrome',
    'auth.json',
  }
}

---@param auth table?
---@return table? auth
function M.Auth(auth)
  for _, name in ipairs(M.auths) do
    local Auth = require(name).Auth
    local _auth = Auth(auth)
    if fn.filereadable(_auth.path) == 1 then
      return _auth
    end
  end
end

return M
