--- init a zhihu answer
local API = require 'zhihu.api.post'.API
local M = {
  API = {
    url = "https://www.zhihu.com/api/v4/questions/%s/draft",
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
    content = tostring(article.root),
    draft_type = article.draft_type,
    delta_time = article.delta_time,
    settings = {
      reshipment_settings = "allowed",
      comment_permission = "all",
      can_reward = article.can_reward,
      tagline = "",
      disclaimer_status = "close",
      disclaimer_type = "none",
      commercial_report_info = {
        is_report = true,
      },
      push_activity = false,
      table_of_contents_enabled = article.table_of_contents,
      thank_inviter_status = "close",
      thank_inviter = "",
    }
  }
  return self:from_body(body, article.question_id)
end

return M
