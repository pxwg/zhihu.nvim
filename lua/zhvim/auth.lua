---get cookies.
---all modules under auth must provide a function `get_cookies()`.
local Cookies = require 'zhvim.auth.auth'.Cookies
local M = {
  auths = {
    require 'zhvim.auth.firefox',
    require 'zhvim.auth.chrome',
    require 'zhvim.auth.pychrome',
  }
}

function M.get_cookies(...)
  for _, auth in ipairs(M.auths) do
    local cookies = auth.get_cookies(...)
    if #tostring(cookies) > 0 then
      return cookies
    end
  end
  return Cookies {}
end

---if you want to customize it, set `M.cookies` by yourself
---@return string
function M.load_cookies(...)
  if M.cookies == nil then
    M.cookies = tostring(M.get_cookies(...))
  end
  return M.cookies
end

return M
