--- init a zhihu image
local md5 = require "md5"
local API = require 'zhihu.api.post'.API
local M = {
  API = {
    url = "https://api.zhihu.com/images",
  }
}

---Reads a file as binary and calculates its SHA256 hash.
---@param file string The absolute path to the file
---@return string hash of the file content
function M.md5(file)
  local f = io.open(file)
  local text = ""
  if f then
    text = f:read"*a"
    f:close()
  end
  return md5.sumhexa(text)
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
---@param file string
---@return table
function M.API:from_file(file)
  local hash = M.md5(file)
  return self:from_hash(hash)
end

return M
