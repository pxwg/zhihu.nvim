--- update a zhihu article
local requests = require "requests"
local json = require 'vim.json'
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/%s/draft",
    headers = {
      ["User-Agent"] =
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36",
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
  api.headers.Cookie = auth.dumps_cookies()
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param id string
---@param title string?
---@param content string?
---@return table
function M.API.from_id(id, title, content)
  title = title or "未命名"
  content = content or ""
  local body = {
    title = title,
    content = content,
    table_of_contents = false,
    delta_time = 30,
    can_reward = false,
  }
  local api = {
    url = M.API.url:format(id),
    data = json.encode(body),
  }
  return M.API(api)
end

---request
---@return table
function M.API:request()
  return requests.patch(self)
end

return M
