local fs = require 'vim.fs'
local json = require 'vim.json'
local uv = require 'luv'
local M = {}

--- TODO: Support windows which do not have `stat` command
local id_file = fs.joinpath(vim.fn.stdpath("data"), "zhvim_buf_ids.json")

---Load IDs from the JSON file
---@return table
local function load_ids()
  local dir = fs.dirname(id_file)
  if uv.fs_stat(dir) == nil then
    vim.fn.mkdir(dir, "p")
  end
  local file = io.open(id_file)
  if file == nil then
    vim.api.nvim_echo({ { "ID file not found, creating a new one: " .. id_file, "WarningMsg" } }, true, {})
    local file = io.open(id_file, "w")
    if file then
      file:write("{}")
      file:close()
    end
    return {}
  end
  local content = file:read "*a"
  file:close()
  local isok, ids = pcall(json.decode, content)
  if not isok then
    ids = {}
  end
  return ids
end

---Save IDs to the JSON file
---@param ids table
local function save_ids(ids)
  local json_content = json.encode(ids)
  local file = io.open(id_file, "w")
  if file then
    file:write(json_content)
    file:close()
  else
    vim.notify("Failed to save IDs to file: " .. id_file, vim.log.levels.ERROR)
  end
end

---Update the ID of a file
---@param filepath string
---@param new_id string
local function update_id(filepath, new_id)
  local ids = load_ids()
  local inode = M.get_inode(filepath)
  if not inode then
    return
  end
  if ids[inode] then
    ids[inode] = new_id
    save_ids(ids)
  else
    vim.notify("No ID found for " .. filepath, vim.log.levels.WARN)
  end
end

---Get the ID of a file based on its inode
---@param filepath string
---@return integer?
function M.get_inode(filepath)
  local stat = uv.fs_stat(filepath)
  if not stat then
    vim.notify("Failed to get inode for " .. filepath, vim.log.levels.ERROR)
    return nil
  end
  return stat.ino
end

---Remove an ID from a file based on its inode
---@param filepath string
function M.remove_id(filepath)
  local ids = load_ids()
  local inode = M.get_inode(filepath)
  if not inode then
    return
  end
  if ids[inode] then
    ids[inode] = nil
    save_ids(ids)
  else
    vim.notify("No ID found for " .. filepath, vim.log.levels.WARN)
  end
end

---Check if a file has an assigned ID
---@param filepath string
---@return string|nil
function M.check_id(filepath)
  local ids = load_ids()
  local inode = M.get_inode(filepath)
  return ids[inode] or nil
end

---Assign an ID to a file based on its inode
---@param filepath string
---@param id string
function M.assign_id(filepath, id)
  local ids = load_ids()
  local inode = M.get_inode(filepath)
  if not inode then
    return
  end
  ids[inode] = id
  save_ids(ids)
end

---Update the ID of a file
---@param filepath string
---@param new_id string
function M.update_id(filepath, new_id)
  if M.check_id(filepath) == nil then
    M.assign_id(filepath, new_id)
  else
    update_id(filepath, new_id)
  end
end

return M
