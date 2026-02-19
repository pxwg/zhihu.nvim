---get cookies from cache
local fs = require 'vim.fs'
local json = require 'vim.json'
local PlatformDirs = require 'platformdirs'.PlatformDirs
local Cookies = require 'auth.auth'.Cookies
local M = {
    cookies_path = fs.joinpath(PlatformDirs { appname = "nvim" }:user_state_dir(), "zhihu.json")
}

---Extract Zhihu cookies from cache
---@param cookies_path string?
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.get_cookies(cookies_path)
    cookies_path = cookies_path or M.cookies_path
    local f = io.open(cookies_path)
    if f then
        local text = f:read "*a"
        f:close()
        return Cookies(json.decode(text))
    end
    return Cookies()
end

---Extract Zhihu cookies from Firefox database
---@param cookies table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
---@param cookies_path string?
---@return boolean
function M.set_cookies(cookies, cookies_path)
    cookies_path = cookies_path or M.cookies_path
    local f = io.open(cookies_path, "w")
    if not f then
        return false
    end
    f:write(json.encode(cookies))
    f:close()
    return true
end

return M
