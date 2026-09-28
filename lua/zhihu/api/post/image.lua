--- init a zhihu image
local API = require 'zhihu.api.post'.API
local M = {
  API = {
    url = "https://api.zhihu.com/images",
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
---@param hash string
---@return table
function M.API:from_hash(hash)
  local body = {
    image_hash = hash,
    source = "article",
  }
  return self:from_body(body)
end

---factory method.
---@param content string
---@return table
function M.API:from_content(content)
  local hash = require "md5".sumhexa(content)
  return self:from_hash(hash)
end

return M
