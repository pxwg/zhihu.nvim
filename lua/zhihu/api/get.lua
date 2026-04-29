--- download a zhihu article or answer
local requests = require "requests"
local dumps_cookies = require 'zhihu.api'.dumps_cookies
local M = {
  url = {
    image = "https://api.zhihu.com/images/%s",
    question = "https://www.zhihu.com/question/%s",
    zhuanlan = "https://zhuanlan.zhihu.com/p/%s",
  },
  API = {
    url = "/answer/%s",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
      ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
      ["accept-language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["upgrade-insecure-requests"] = "1",
      ["sec-fetch-dest"] = "document",
      ["sec-fetch-mode"] = "navigate",
      ["sec-fetch-site"] = "none",
      ["sec-fetch-user"] = "?1",
      ["priority"] = "u=0, i",
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
  api.headers.Cookie = dumps_cookies()
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---lua < 5.3 use double as number, which result in overflow
---@param id string
---@param question_id string?
---@param image boolean?
---@return table
function M.API.from_id(id, question_id, image)
  local api = {}
  if question_id then
    local field = ""
    if tonumber(id) then
      field = M.API.url:format(id)
    end
    api.url = M.url.question:format(question_id) .. field
  elseif image then
    api.url = M.url.image:format(id)
  else
    api.url = M.url.zhuanlan:format(id)
  end
  return M.API(api)
end

---request
---@return table
function M.API:request()
  return requests.get(self)
end

return M
