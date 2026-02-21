---get cookies from json cache
---@module auth.json
local fs = require 'vim.fs'
local json = require 'vim.json'
local PlatformDirs = require 'platformdirs'.PlatformDirs
local Cookies = require 'auth.auth'.Cookies
local M = {
  Auth = {
    path = fs.joinpath(PlatformDirs { appname = "nvim" }:user_state_dir(), "cookies.json")
  }
}

---@param auth table?
---@return table auth
function M.Auth:new(auth)
  auth = auth or {}
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
  local f = io.open(self.path)
  local text = "{}"
  if f then
    text = f:read "*a"
    f:close()
  end
  local cookies = json.decode(text)[host]
  return Cookies(cookies)
end

---add cookies to cache
---@param host string The host for which to retrieve cookies.
---@param cookies table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
---@return boolean
function M.Auth:set_cookies(host, cookies)
  local f = io.open(self.path, "w+")
  if f == nil then
    return false
  end
  local text = f:read "*a"
  local data = {}
  if text ~= "" then
    data = json.decode(text)
  end
  data[host] = cookies
  text = json.encode(data)
  f:write(text)
  f:close()
  return true
end

return M
