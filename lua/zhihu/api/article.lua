--- publish a zhihu article
local json = require 'vim.json'
local null = require 'cjson'.null
local uuid = require 'uuid'
uuid.set_rng(uuid.rng.math_random())
local API = require 'zhihu.api'.API
local M = {
  API = {
    url = "https://www.zhihu.com/api/v4/content/publish",
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
  local disclaimer_type = "none"
  local disclaimer_status = "closed"
  local pc_business_params = {
    column = null,
    commentPermission = "anyone",
    disclaimer_type = disclaimer_type,
    disclaimer_status = disclaimer_status,
    table_of_contents_enabled = article.table_of_contents,
    commercial_report_info = { commercial_types = {} },
    commercial_zhitask_bind_info = null,
    canReward = false
  }
  local body = {
    action = "article",
    data = {
      publish = { traceId = os.date("%s") .. "," .. uuid.v4() },
      extra_info = {
        publisher = "pc",
        pc_business_params = json.encode(pc_business_params)
      },
      draft = {
        disabled = 1,
        id = article.itemId,
        isPublished = false,
      },
      commentsPermission = { comment_permission = "anyone" },
      creationStatement = {
        disclaimer_type = disclaimer_type,
        disclaimer_status = disclaimer_status,
      },
      contentsTables = { table_of_contents_enabled = article.table_of_contents },
      commercialReportInfo = { isReport = 0 },
      appreciate = { can_reward = article.reward, tagline = "" },
      hybridInfo = {},
    }
  }

  return self:from_body(body)
end

return M
