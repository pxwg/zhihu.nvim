--- update a zhihu article
local requests = require "requests"
local API = require 'zhihu.api'.API
local M = {
  API = {
    url = "https://zhuanlan.zhihu.com/api/articles/%s/draft",
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
    delta_time = article.delta_time,
  }
  if article.titleImage then
    body.titleImage = tostring(article.titleImage)
    body.isTitleImageFullScreen = article.isTitleImageFullScreen
  end
  if article.root then
    body.content = tostring(article.root)
    body.title = article.title
    body.table_of_contents = article.table_of_contents
    body.can_reward = article.can_reward
  end
  return self:from_body(body, article.itemId)
end

---request
---@return table
function M.API:request()
  return requests.patch(self)
end

return M
