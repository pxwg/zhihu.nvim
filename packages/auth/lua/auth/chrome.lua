---get cookies from chrome cookies database
local uv = require 'vim.uv'
local fs = require 'vim.fs'
local fn = require 'vim.fn'
local PlatformDirs = require 'platformdirs'.PlatformDirs
local chrome_cookie = require 'chrome_cookie'
local Cookies = require 'auth.auth'.Cookies
local M = {
  Auth = {
  }
}

---Get the Chrome Cookies file path for the current user
---@return string cookies_path Full path to Cookies file or nil if not found
function M.get_cookies_path()
  local sysname = uv.os_uname().sysname

  local appname = "Chrome"
  if sysname == "Linux" then
    appname = "google-chrome"
  elseif sysname == "Darwin" then
    -- https://github.com/tox-dev/platformdirs/discussions/409
    appname = "Google/Chrome"
  end
  local dir = PlatformDirs { appname = appname, appauthor = "Google" }:user_config_dir()
  return fs.joinpath(dir, "Default", "Cookies")
end

---@param auth table?
---@return table auth
function M.Auth:new(auth)
  auth = auth or {}
  auth.path = auth.path or M.get_cookies_path()
  if fn.filereadable(auth.path) == 1 then
    auth.password = auth.password or chrome_cookie.get_chrome_password()
  end
  setmetatable(auth, {
    __index = self
  })
  return auth
end

setmetatable(M.Auth, {
  __call = M.Auth.new
})

---extract cookies
---@param host string The host for which to retrieve cookies.
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.Auth:get_cookies(host)
  local cookies = chrome_cookie.get_cookies_for_host(self.path, self.password, host)
  for k, v in pairs(cookies) do
    -- HACK: Remove the first 56 rubbish characters from the cookie value
    cookies[k] = v:sub(57)
  end
  return Cookies(cookies)
end

return M
