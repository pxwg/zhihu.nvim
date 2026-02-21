---meta

---@class Article
---@field itemId string? answer id or article id, will create one if empty
---@field question_id string? question_id id, empty if it is an article
---@field title string? article title or question title
---@field authorName string? author name
---@field isPublished boolean? set automatically
---https://www.zhihu.com/creator/editor-setting
---@field can_reward boolean? 送礼物设置
---@field comment_permission "all"? 评论权限
---@field reshipment_settings "allowed"? 转载设置
---@field table_of_contents boolean? enable TOC
---@field isTitleImageFullScreen boolean? article title image is fullscreen
---@field draft_type "normal"?
---@field delta_time integer?
---@field disclaimer_status "closed" | "open"?
---无/包含剧透/包含医疗建议/虚构创作/包含理财内容/包含 AI 辅助创作
---@field disclaimer_type "none" | "spoiler" | "medical_advice" | "fictional_creation" | "contain_finance" | "ai_creation"?
---@field thank_inviter_status "close"?
---@field thank_inviter string?
---@field root table? set automatically
---@field reader function? a function to convert HTML to other markup languages
---@field writer function? a function to convert other markup languages to HTML

---@class upload_token
---@field access_id string
---@field access_key string
---@field access_token string
---@field access_timestamp number

---@class upload_file
---@field image_id string
---@field object_key string
---@field state number

---@class upload_response
---@field upload_vendor string
---@field upload_token upload_token
---@field upload_file upload_file
