---lazy load
-- luacheck: ignore 111 113
---@diagnostic disable: undefined-global
local M = {
  opts = {
    article = {}
  }
}

---set up
---@param opts table
function M.setup(opts)
  M.opts = vim.tbl_extend(M.opts, opts, "force")
end

---override default value, only run once
function M.init()
  if M.is_init then
    return
  end
  local Article = require 'zhihu.article.html'.Article
  for k, v in pairs(M.opts.article) do
    Article[k] = v
  end
  M.is_init = true
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
      M.init()
      require "zhihu.article".read_cb()
    end
  })
  vim.api.nvim_create_autocmd("BufWriteCmd", {
    pattern = "zhihu://*",
    group = augroup_id,
    callback = function()
      M.init()
      require "zhihu.article".write_cb()
    end
  })
end

return M
