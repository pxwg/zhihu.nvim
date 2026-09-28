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

---@class Uploader: upload_response
---@field status string

---@class image_response
---@field animation_cover_src string? "https://pic-private.zhihu.com/v2-b79782844dae1e15aa9419c502a84f0a~resize:1440:q75.png?source=1f5c5e47&expiration=1790586320&auth_key=1790586320-0-0-cd2ec5c6bc172c919fc2b2bcf6e94598&protocol=v2&sampling=False&animatedImagePlayCount=1&overTime=60&incremental=False&sceneCode=article_draft_web&animatedImageAutoPlay=False&retryCount=3&precoder=False"
---@field original_hash string? "v2-b79782844dae1e15aa9419c502a84f0a"
---@field original_src string? "https://pic-private.zhihu.com/v2-b79782844dae1e15aa9419c502a84f0a~resize:0:q75.png?source=1f5c5e47&expiration=1790586320&auth_key=1790586320-0-0-6f197d5d0c8d292a296ad5547a0b36c5&protocol=v2&sampling=False&animatedImagePlayCount=1&overTime=60&incremental=False&sceneCode=article_draft_web&animatedImageAutoPlay=False&retryCount=3&precoder=False"
---@field src string? "https://pic-private.zhihu.com/v2-b79782844dae1e15aa9419c502a84f0a~resize:1440:q75.png?source=1f5c5e47&expiration=1790586320&auth_key=1790586320-0-0-cd2ec5c6bc172c919fc2b2bcf6e94598&protocol=v2&sampling=False&animatedImagePlayCount=1&overTime=60&incremental=False&sceneCode=article_draft_web&animatedImageAutoPlay=False&retryCount=3&precoder=False"
---@field status "success" | "processing" | "init" | string?
---@field watermark string? "original"
---@field watermark_hash string? "v2-584ab838d9caedf0343ed6e82fa357f8"
---@field watermark_src string? "https://pic-private.zhihu.com/v2-584ab838d9caedf0343ed6e82fa357f8~resize:1440:q75.png?source=1f5c5e47&expiration=1790586320&auth_key=1790586320-0-0-5b24a1460059ca5a958d9a37684d27ce&protocol=v2&sampling=False&animatedImagePlayCount=1&overTime=60&incremental=False&sceneCode=article_draft_web&animatedImageAutoPlay=False&retryCount=3&precoder=False"

---@class Image: image_response
---@field src_type "src" | "original_src" | "watermark_src" | "animation_cover_src"?
