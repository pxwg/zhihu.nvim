---lazy load
-- luacheck: ignore 111 113
---@diagnostic disable: undefined-global
local M = {}

---set up
function M.setup()
  M.create_autocmds()
end

---create autocmds
---TODO: callback for exit
---@param augroup_id integer?
function M.create_autocmds(augroup_id)
  augroup_id = augroup_id or vim.api.nvim_create_augroup("zhihu", {})
  vim.api.nvim_create_autocmd({ "BufReadCmd", "SessionLoadPost" }, {
    pattern = "zhihu://*",
    group = augroup_id,
    callback = function()
      require "zhihu.article".read_cb()
    end
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    pattern = "zhihu://*",
    group = augroup_id,
    callback = function()
      require "zhihu.article".write_cb()
    end
  })
end

return M
