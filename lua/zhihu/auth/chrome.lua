---get cookies from chrome by chrome_cookie
local uv = require 'vim.uv'
local fs = require 'vim.fs'
local PlatformDirs = require 'platformdirs'.PlatformDirs
local chrome_cookie = require 'chrome_cookie'
local Cookies = require 'zhihu.auth.auth'.Cookies
local M = {}

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

---Extract Zhihu cookies from Chrome database
---@param cookie_path string?
---@param password string?
---@param host string? The host for which to retrieve cookies.
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.get_cookies(cookie_path, password, host)
  cookie_path = cookie_path or M.get_cookies_path()
  password = password or chrome_cookie.get_chrome_password()
  host = host or ".zhihu.com"
  local cookies = chrome_cookie.get_cookies_for_host(cookie_path, password, host)
  for k, v in pairs(cookies) do
    -- HACK: Remove the first 56 rubbish characters from the cookie value
    cookies[k] = v:sub(57)
  end
  return Cookies(cookies)
end

return M
