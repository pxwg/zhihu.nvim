--- get similar topics
local requests = require "requests"
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/autocomplete/topics?token=%s&max_matches=%d&use_similar=0&topic_filter=1",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
      ["Accept-Encoding"] = "gzip, deflate, br, zstd",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["x-requested-with"] = "fetch",
      referer = "https://zhuanlan.zhihu.com/p/%s/edit",
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
  return api
end

---request
---@return table
function M.API:request()
  return requests.get(self)
end

return M
