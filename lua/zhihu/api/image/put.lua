--- upload a zhihu image
local requests = require "requests"
local guess = require 'mimetypes'.guess
local sha1 = require 'sha1'
local base64 = require 'vim.base64'
local M = {
  string_to_sign = [[PUT

%s
%s
x-oss-date:%s
x-oss-security-token:%s
x-oss-user-agent:%s
/zhihu-pics/%s]],
  API = {
    url = "https://zhihu-pics-upload.zhimg.com/%s",
    headers = {
      ["User-Agent"] = "aliyun-sdk-js/6.8.0 Firefox 137.0 on OS X 10.15",
      ["Accept-Encoding"] = "gzip, deflate, br, zstd",
      ["Content-Type"] = "application/octet-stream",
      ["Accept-Language"] = "zh-CN,zh;q=0.8,zh-TW;q=0.7,zh-HK;q=0.5,en-US;q=0.3,en;q=0.2",
      ["x-oss-user-agent"] = "aliyun-sdk-js/6.8.0 Firefox 137.0 on OS X 10.15",
      ["Authorization"] = "OSS %s:%s",
    }
  }
}

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

---@param api table?
---@return table api
function M.API:new(api)
  api = api or {}
  setmetatable(api, {
    __index = self
  })
  return api
end

setmetatable(M.API, {
  __call = M.API.new
})

---factory method.
---@param file string
---@param image upload_response
---@return table
function M.API.from_image(file, image)
  return M.API.from_upload_token(file, image.upload_file.object_key, image.upload_token)
end

---factory method.
---@param file string
---@param object_key string
---@param upload_token upload_token
---@return table
function M.API.from_upload_token(file, object_key, upload_token)
  return M.API.from_access_token(file, object_key, upload_token.access_id, upload_token.access_token, upload_token.access_key)
end

---factory method.
---@param file string
---@param object_key string
---@param access_id string
---@param access_token string
---@param access_key string
---@return table
function M.API.from_access_token(file, object_key, access_id, access_token, access_key)
  local api = {}
  local f = io.open(file, "rb")
  if f then
    api.data = f:read "*a"
    f:close()
  end
  api = M.API(api)
  api.url = api.url:format(object_key)
  api.headers["Content-Type"] = guess(file) or api.headers["Content-Type"]
  api.headers["x-oss-date"] = os.date("!%a, %d %b %Y %H:%M:%S GMT")
  api.headers["x-oss-security-token"] = access_token
  local string_to_sign = M.string_to_sign:format(api.headers["Content-Type"], api.headers["x-oss-date"],
    api.headers["x-oss-date"], access_token, api.headers["User-Agent"], object_key)
  local signature = base64.encode(sha1.hmac_binary(access_key, string_to_sign))
  api.headers["Authorization"] = api.headers["Authorization"]:format(access_id, signature)
  return api
end

---request
---@return table
function M.API:request()
  return requests.put(self)
end

return M
