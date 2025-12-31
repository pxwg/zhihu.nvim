---get cookies from chrome by pychrome
local json = require 'vim.json'
local fn = require 'vim.fn'
local fs = require 'vim.fs'
local Cookies = require 'zhihu.auth.auth'.Cookies
local M = {}

---get python executable from vim
---@return string
function M.get_python_executable()
  vim.cmd [[
    redir => g:py
    pyx print(sys.executable)
    redir END
  ]]
  return fn.trim(vim.g.py)
end

---Extract Zhihu cookies from Chrome database
---@return table<string, string> cookies A table where keys are cookie names and values are cookie values for the specified host.
function M.get_cookies(chrome_path, port, timeout, url)
  chrome_path = chrome_path or "/usr/bin/chrome"
  port = port or 9222
  timeout = timeout or 10
  url = url or "https://www.zhihu.com/"
  local python_executable = M.get_python_executable()
  local python_script_chrome = fs.joinpath(
    fs.dirname(debug.getinfo(1).source:match("@?(.*)")),
    "scripts", "auth_chrome.py"
  )
  local chrome_cmd = {
    chrome_path,
    "--remote-debugging-port=" .. port,
    "--user-data-dir=" .. fn.tempname(),
    "--no-first-run",
    "--no-default-browser-check",
    "--homepage=about:blank",
    "--disable-default-apps",
  }
  local id = fn.jobstart(chrome_cmd, { detach = true })

  local script_cmd = {
    python_executable,
    python_script_chrome,
    "--timeout",
    tostring(timeout),
    "--url",
    url,
    "--port",
    tostring(port),
  }
  local result = vim.system(script_cmd, { text = true }):wait()

  fn.jobstop(id)
  if result.code ~= 0 then
    return {}
  end
  return Cookies(json.decode(result.stdout or "[]")[1] or {})
end

return M
