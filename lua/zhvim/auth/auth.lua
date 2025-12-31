---Provide a class for cookies
local M = {
  Cookies = {}
}

---@param cookies table?
---@return table cookies
function M.Cookies:new(cookies)
  cookies = cookies or {}
  setmetatable(cookies, {
    __tostring = self.tostring,
    __index = self
  })
  return cookies
end

---Convert a table<string, string> to a valid Cookie string
---@return string
function M.Cookies:tostring()
  local cookie = {}
  for k, v in pairs(self) do
    table.insert(cookie, k .. "=" .. v)
  end
  return table.concat(cookie, "; ")
end

setmetatable(M.Cookies, {
  __call = M.Cookies.new
})

return M
