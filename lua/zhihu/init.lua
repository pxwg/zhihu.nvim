local M = {}

function M.setup()
  require("zhihu.article").create_autocmds()
end

return M
