---get cookies from firefox by lsqlite3
local uv = require 'vim.uv'
local fs = require 'vim.fs'
local fn = require 'vim.fn'
local lsqlite3 = require "lsqlite3"
local PlatformDirs = require 'platformdirs'.PlatformDirs
local Cookies = require 'auth.auth'.Cookies
local M = {}

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

---Extract Zhihu cookies from Firefox database
---@param host string The host for which to retrieve cookies.
---@param cookies_path string?
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.get_cookies(host, cookies_path)
  cookies_path = cookies_path or M.get_cookies_path()
  if fn.filereadable(cookies_path) then
    return Cookies()
  end
  local db = lsqlite3.open(cookies_path)

  local sql_file = fs.joinpath(
    fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
    "scripts", "firefox.sql"
  )
  local f = io.open(sql_file)
  local sql = ""
  if f ~= nil then
    sql = f:read()
    if sql:sub(1, 2) == "#!" then
      sql = f:read "*a"
    else
      sql = sql .. f:read "*a"
    end
    f:close()
  end
  sql = sql:format(host)
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
