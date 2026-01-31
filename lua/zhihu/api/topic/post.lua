--- attach topics to a zhihu article
local API = require 'zhihu.api'.API
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/%s/topics",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
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
  api = API(api)
  setmetatable(api, {
    __index = self
  })
  return api
end

return M
