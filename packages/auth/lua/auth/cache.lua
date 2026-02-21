---cache cookies
---@module auth.cache
local Auth = require 'auth.chained'.Auth
local M = {
  Auth = {
    cookies_map = {}
  }
}

---@param auth table?
---@return table auth
function M.Auth:new(auth)
  auth = auth or {}
  auth.auth = auth.auth or Auth()
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
  if self.cookies_map[host] == nil then
    self.cookies_map[host] = self.auth:get_cookies(host)
    self:set_cookies(host, self.cookies_map[host])
  end
  return self.cookies_map[host]
end

---add cookies to cache
---@param host string The host for which to retrieve cookies.
---@param cookies table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
---@return boolean
function M.Auth:set_cookies(host, cookies)
  if self.auth.set_cookies then
    return self.auth:set_cookies(host, cookies)
  end
  return true
end

return M
