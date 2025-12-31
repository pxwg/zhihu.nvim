--- init a zhihu article
local requests = require "requests"
local json = require 'vim.json'
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/drafts",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36",
      ["Content-Type"] = "application/json",
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
  api.headers.Cookie = auth.load_cookies()
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param title string?
---@param content string?
---@return table
function M.API.from_html(title, content)
  title = title or "未命名"
  content = content or ""
  local body = {
    title = title,
    content = content,
    delta_time = 0,
    can_reward = false,
  }
  local api = {
    data = json.encode(body),
  }
  return M.API(api)
end

---request
---@return table
function M.API:request()
  return requests.post(self)
end

return M
