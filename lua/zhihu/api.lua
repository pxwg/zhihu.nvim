---a common class for json API
local requests = require "requests"
local json = require 'vim.json'
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
      ["Content-Type"] = "application/json",
      ["Accept-Encoding"] = "gzip, deflate, br, zstd",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["x-requested-with"] = "fetch",
    }
  }
}

---@param api table?
---@return table api
function M.API:new(api)
  api = api or {}
  setmetatable(api, {
    __index = self
  })
  api.headers.Cookie = auth.dumps_cookies()
  api.headers["x-xsrftoken"] = auth.cookies._xsrf
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param body table
---@param id string?
---@return table
function M.API:from_body(body, id)
  local api = {
    url = self.url:format(id),
    data = json.encode(body),
  }
  return self(api)
end

---request
---@return table
function M.API:request()
  return requests.post(self)
end

return M
