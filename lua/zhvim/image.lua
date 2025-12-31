--- a class to get/post/patch zhihu image in HTML
local Post = require 'zhvim.api.image.post'.API
local Put = require 'zhvim.api.image.put'.API
local fs = require 'vim.fs'
local md5 = require 'zhvim.api.image.post'.md5
local infer_mime_type = require 'zhvim.api.image.put'.infer_mime_type
local M = {
  Image = {
    mime = Put.headers["Content-Type"],
    url = "https://picx.zhimg.com/v2-%s.%s",
  }
}

---@param image table?
---@return table image
function M.Image:new(image)
  image = image or {}
  image.file = fs.normalize(fs.abspath(image.file))
  image.hash = md5(image.file)
  image.mime = infer_mime_type(image.file)
  image.url = M.Image.url:format(image.hash, image.mime:match("[^/]+$") or "")
  setmetatable(image, {
    __index = self
  })
  return image
end

setmetatable(M.Image, {
  __call = M.Image.new
})

---update image
---@return boolean
function M.Image:update()
  local api = Post.from_file(self.file)
  local resp = api:request()
  if resp.status_code ~= 200 then
    self.status = resp.status
    return false
  end
  local upload_result = resp.json()
  -- image exists
  if upload_result.upload_file.state == 1 then
    return true
  end
  -- upload_result.upload_file.state == 2
  local upload_token = upload_result.upload_token
  api = Put.from_file(self.file, upload_token.access_id, upload_token.access_token, upload_token.access_key)
  resp = api:request()
  if resp.status_code ~= 200 then
    self.status = resp.status
    return false
  end
  return true
end

return M
