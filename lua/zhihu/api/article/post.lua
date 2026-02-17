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
  return api
end

setmetatable(M.API, {
  __index = API,
  __call = M.API.new
})

---factory method.
---@param article table
---@return table
function M.API:from_article(article)
  local body = {
    title = article.title,
    content = tostring(article.root),
    delta_time = article.delta_time,
    can_reward = article.can_reward,
  }
  return self:from_body(body)
end

return M
