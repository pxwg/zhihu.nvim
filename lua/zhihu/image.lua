--- a class to get/post/patch zhihu image in HTML
local json = require 'vim.json'
local Post = require 'zhihu.api.image.post'.API
local Put = require 'zhihu.api.image.put'.API
local M = {
  url = "https://picx.zhimg.com/%s",
  Image = {
    upload_file = {}
  }
}

---@param image table?
---@return table image
function M.Image:new(image)
  image = image or {}
  setmetatable(image, {
    __tostring = self.tostring,
    __index = self
  })
  return image
end

setmetatable(M.Image, {
  __call = M.Image.new
})

---Convert a table<string, string> to string
---@return string
function M.Image:tostring()
  return M.url:format(self.upload_file.object_key or "")
end

---create from a file path
---@param file string
---@return table image
function M.Image.from_file(file)
  local api = Post:from_file(file)
  local resp = api:request()
  if resp.status_code ~= 200 then
    return M.Image { upload_file = { image_id = resp.status } }
  end
  local image = M.Image(resp.json())
  -- image exists
  if image.upload_file.state == 1 then
    image.upload_file.object_key = ("v2-%s"):format(json.decode(api.data).image_hash)
    return image
  end
  assert(image.upload_file.state == 2)

  api = Put.from_image(file, image)
  resp = api:request()
  if resp.status_code == 200 then
    image.upload_file.state = 1
  else
    image.upload_file.image_id = resp.status
  end
  return image
end

---create from a file path
---@param hash string
---@return table image
function M.Image.from_hash(hash)
  local api = Post:from_hash(hash)
  local resp = api:request()
  local image
  if resp.status_code ~= 200 then
    image = { upload_file = { image_id = resp.status } }
  end
    image = resp.json()
  return M.Image(image)
end

return M
