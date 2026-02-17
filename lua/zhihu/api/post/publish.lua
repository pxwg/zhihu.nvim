--- publish a zhihu article or answer
-- luacheck: ignore 111 113
---@diagnostic disable: undefined-global
local json = require 'cjson'
local uuid = require 'uuid'
uuid.set_rng(uuid.rng.math_random())
local API = require 'zhihu.api.post'.API
local M = {
  empty_array_mt = vim and vim.empty_dict() or json.empty_array_mt,
  pc_business_params = {
    ["reward_setting"] = {
      ["can_reward"] = false
    },
    ["reshipment_settings"] = "allowed",
    ["thank_inviter"] = "",
    ["comment_permission"] = "all",
    ["commercial_zhitask_bind_info"] = json.null,
    ["column"] = json.null,
    ["is_report"] = false,
    ["thank_inviter_status"] = "close",
    ["table_of_contents_enabled"] = false,
    ["disclaimer_status"] = "close",
    ["disclaimer_type"] = "none",
    ["commercial_report_info"] = {
      ["is_report"] = false
    }
  },
  API = {
    url = "https://www.zhihu.com/api/v4/content/publish",
  }
}

---get trace id
---@return string
function M.get_trace_id()
  return os.date("%s") .. "," .. uuid.v4()
end

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
    action = article.question_id and "answer" or "article",
    data = {
      -- if uses {}
      -- 内容格式错误
      hybridInfo = M.empty_array_mt,
      toFollower = M.empty_array_mt,
      publish = { traceId = M.get_trace_id() },
      extra_info = {
        publisher = "pc",
        question_id = article.question_id,
        include =
        "is_visible,paid_info,paid_info_content,has_column,admin_closed_comment,reward_info,annotation_action,annotation_detail,collapse_reason,is_normal,is_sticky,collapsed_by,suggest_edit,comment_count,thanks_count,favlists_count,can_comment,content,editable_content,voteup_count,reshipment_settings,comment_permission,created_time,updated_time,review_info,relevant_info,question,excerpt,attachment,content_source,is_labeled,endorsements,reaction_instruction,ip_info,relationship.is_authorized,voting,is_thanked,is_author,is_nothelp,is_favorited;author.vip_info,kvip_info,badge[*].topics;settings.table_of_content.enabled",
        pc_business_params = json.encode(M.pc_business_params)
      },
      draft = {
        disabled = 1,
        id = not article.question_id and article.itemId or nil,
        contentId = article.question_id and article.itemId,
        isPublished = article.isPublished,
      },
      publishSwitch = {
        draft_type = article.draft_type,
      },
      creationStatement = {
        disclaimer_type = article.disclaimer_type,
        disclaimer_status = article.disclaimer_status,
      },
      contentsTables = { table_of_contents_enabled = false },
      commercialReportInfo = { isReport = 0 },
      thanksInvitation = {
        thank_inviter_status = article.thank_inviter_status,
        thank_inviter = article.thank_inviter,
      },
    }
  }

  -- 内容格式错误
  -- https://www.zhihu.com/creator/editor-setting
  if article.reshipment_settings ~= nil then
    body.reprint = { reshipment_settings = article.reshipment_settings }
  end
  if article.comment_permission ~= nil then
    body.commentsPermission = { comment_permission = article.comment_permission }
  end
  if article.can_reward ~= nil then
    body.appreciate = { can_reward = article.can_reward }
  end

  -- 发布失败
  if article.question_id then
    body.hybrid = {
      html = tostring(article.root),
    }
  end
  return self:from_body(body)
end

return M
