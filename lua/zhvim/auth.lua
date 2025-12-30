---get cookies.
---all modules under auth must provide a function `get_cookies()`.
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
    if #M.stringify_cookies(cookies) > 0 then
      return cookies
    end
  end
  return {}
end

---Convert a table<string, string> to a valid Cookie string
---@param t table<string, string>
---@return string
function M.stringify_cookies(t)
  local cookie = {}
  for k, v in pairs(t) do
    table.insert(cookie, k .. "=" .. v)
  end
  return table.concat(cookie, "; ")
end

---if you want to customize it, set `M.cookies` by yourself
---@return string
function M.load_cookies(...)
  if M.cookies == nil then
    M.cookies = M.stringify_cookies(M.get_cookies(...))
  end
  return M.cookies
end

return M
