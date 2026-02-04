--- init a zhihu answer
local API = require 'zhihu.api'.API
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
---@param content string
---@param id string
---@return table
function M.API:from_html(content, id)
  local body = {
    content = content,
    draft_type = "normal",
    delta_time = 30,
    settings = {
      reshipment_settings = "allowed",
      comment_permission = "all",
      can_reward = false,
      tagline = "",
      disclaimer_status = "close",
      disclaimer_type = "none",
      commercial_report_info = {
        is_report = true,
      },
      push_activity = false,
      table_of_contents_enabled = false,
      thank_inviter_status = "close",
      thank_inviter = "",
    }
  }
  return self:from_body(body, id)
end

return M
