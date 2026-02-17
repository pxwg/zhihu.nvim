---get cookies.
---all modules under auth must provide a function `get_cookies()`.
local set_cookies = require 'zhihu.auth.cache'.set_cookies
local Cookies = require 'zhihu.auth.auth'.Cookies
local M = {
  auths = {
    'zhihu.auth.firefox',
    'zhihu.auth.cache',
    'zhihu.auth.chrome',
  }
}

---Extract Zhihu cookies from cache
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.get_cookies(...)
  for _, name in ipairs(M.auths) do
    local auth = require(name)
    local cookies = auth.get_cookies(...)
    if #tostring(cookies) > 0 then
      if auth ~= require 'zhihu.auth.cache' then
        set_cookies(cookies)
      end
      return cookies
    end
  end
  return Cookies {}
end

---if you want to customize it, set `M.cookies` by yourself
---@return string
function M.dumps_cookies(...)
  if M.cookies == nil then
    M.cookies = (M.get_cookies(...))
  end
  return tostring(M.cookies)
end

return M
