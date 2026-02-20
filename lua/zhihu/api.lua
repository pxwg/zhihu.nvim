---cache auth
local M = {
  auth = require 'auth.cache'.Auth()
}

---dumps cookies
---@param host string?
---@return string
function M.dumps_cookies(host)
  host = host or ".zhihu.com"
  return tostring(M.auth:get_cookies(host))
end

return M
