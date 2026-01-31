--- publish a zhihu article
local requests = require "requests"
local json = require 'vim.json'
local null = require 'cjson'.null
local uuid = require 'uuid'
uuid.set_rng(uuid.rng.math_random())
local auth = require 'zhihu.auth'
local M = {
  API = {
    url = "https://www.zhihu.com/api/v4/content/publish",
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
  setmetatable(api, {
    __index = self
  })
  api.headers.Cookie = auth.dumps_cookies()
  api.headers["x-xsrftoken"] = auth.cookies._xsrf

  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param article table
---@return table
function M.API.from_article(article)
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
