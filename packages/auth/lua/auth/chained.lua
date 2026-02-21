---get cookies from many auths by an order
---@module auth.chained
local fn = require 'vim.fn'
local Cookies = require 'auth.auth'.Cookies
local M = {
  Auth = {
  }
}

---@param auth table?
---@return table auth
function M.Auth:new(auth)
  auth = auth or {}
  if auth.auths == nil then
    auth.auths = {}
    for _, name in ipairs {
      'auth.firefox',
      'auth.chrome',
      'auth.json',
    } do
      local Auth = require(name).Auth
      local _auth = Auth()
      if _auth.set_cookies or fn.filereadable(_auth.path) == 1 then
        table.insert(auth.auths, _auth)
      end
    end
  end
  setmetatable(auth, {
    __index = self
  })
  return auth
end

setmetatable(M.Auth, {
  __call = M.Auth.new
})

---extract cookies from cache
---@param host string The host for which to retrieve cookies.
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.Auth:get_cookies(host)
  for _, auth in ipairs(self.auths) do
    local cookies = auth:get_cookies(host)
    if #tostring(cookies) > 0 then
      return cookies
    end
  end
  return Cookies()
end

---add cookies to cache
---@param host string The host for which to retrieve cookies.
---@param cookies table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
---@return boolean
function M.Auth:set_cookies(host, cookies)
  local ret = true
  for _, auth in ipairs(self.auths) do
    if auth.set_cookies then
      ret = ret and auth:set_cookies(host, cookies)
    end
  end
  return ret
end

return M
