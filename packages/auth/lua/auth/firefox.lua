---get cookies from firefox cookies database
---@module auth.firefox
local uv = require 'vim.uv'
local uri = require 'vim.uri'
local fs = require 'vim.fs'
local lsqlite3 = require "lsqlite3"
local datafile = require 'datafile'
local PlatformDirs = require 'platformdirs'.PlatformDirs
local Cookies = require 'auth.auth'.Cookies
local M = {
  sql = '',
  Auth = {}
}
local _f = datafile.open("conf/firefox.sql") or
    io.open(debug.getinfo(1).source:match("@?(.*/)[^/]+/[^/]+/[^/]+$") .. "etc/conf/firefox.sql")
if _f then
  M.sql = _f:read()
  if M.sql:sub(1, 2) == "#!" then
    M.sql = _f:read "*a"
  else
    M.sql = M.sql .. _f:read "*a"
  end
  _f:close()
end

---Get the Firefox cookies.sqlite path for the current user
---@return string cookies_path Full path to Cookies file or nil if not found
function M.get_cookies_path()
  local dir = fs.joinpath(uv.os_homedir(), ".mozilla", "firefox")
  local sysname = uv.os_uname().sysname
  if sysname ~= "Linux" then
    dir = fs.joinpath(PlatformDirs { appname = "Firefox" }:user_config_dir(), "Profiles")
  end
  local basename = "%.default"
  for name in fs.dir(dir) do
    if name:match(basename) then
      basename = name
      break
    end
  end
  return fs.joinpath(dir, basename, "cookies.sqlite")
end

---@param auth table?
---@return table auth
function M.Auth:new(auth)
  auth = auth or {}
  auth.path = auth.path or M.get_cookies_path()
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
  local url = uri.uri_from_fname(self.path) .. "?immutable=1&mode=ro"
  local db = lsqlite3.open(url, lsqlite3.OPEN_READONLY + lsqlite3.OPEN_URI)

  local sql = M.sql:format(host)
  if db:exec(sql) ~= 0 then
    return Cookies()
  end
  local cookies = {}
  for k, v in db:urows(sql) do
    cookies[k] = v
  end
  return Cookies(cookies)
end

return M
