--- init a zhihu article
local API = require 'zhihu.api'.API
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/drafts",
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
  api.headers.Cookie = auth.dumps_cookies()
  return api
end

setmetatable(M.API, {
  __index = API,
  __call = M.API.new
})

---factory method.
---@param title string?
---@param content string?
---@return table
function M.API:from_html(title, content)
  title = title or "未命名"
  content = content or ""
  local body = {
    title = title,
    content = content,
    delta_time = 0,
    can_reward = false,
  }
  return self:from_body(body)
end

return M
