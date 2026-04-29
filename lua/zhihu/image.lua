--- a class to get/post/patch zhihu image in HTML
local socket = require "socket"
local Post = require 'zhihu.api.post.image'.API
local Put = require 'zhihu.api.put'.API
local Get = require 'zhihu.api.get'.API
local M = {
  sleep_seconds = 0,
  max_retry = 10,
  Image = {
    src = "",
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
  return self.src
end

---create from an id
---@param id string
---@return table image
function M.Image.from_id(id)
  local api = Get.from_id(id, nil, true)
  local resp
  for _ = 1, M.max_retry do
    resp = api:request()
    if resp.status_code == 200 and resp.json().status == "success" then
      return M.Image(resp.json())
    end
    socket.sleep(M.sleep_seconds)
  end
  return M.Image { src = resp.status }
end

---create from a file path
---@param file string
---@return table image
function M.Image.from_file(file)
  local api = Post:from_file(file)
  local resp = api:request()
  if resp.status_code ~= 200 then
    return M.Image { src = resp.status }
  end
  local image = M.Image(resp.json())
  -- image exists
  if image.upload_file.state == 1 then
    return M.Image.from_id(image.upload_file.image_id)
  end
  assert(image.upload_file.state == 2)

  api = Put.from_image(file, image)
  resp = api:request()
  if resp.status_code == 200 then
    image.upload_file.state = 1
  else
    image.src = resp.status
  end
  return M.Image.from_id(image.upload_file.image_id)
end

---create from a file path
---@param hash string
---@return table image
function M.Image.from_hash(hash)
  local api = Post:from_hash(hash)
  local resp = api:request()
  local image
  if resp.status_code ~= 200 then
    image = M.Image { src = resp.status }
  end
  image = resp.json()
  return M.Image(image)
end

return M
