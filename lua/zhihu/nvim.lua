---APIs for neovim
---@diagnostic disable: undefined-global
-- luacheck: ignore 111 113
local uv = require 'luv'
local M = {}

---open a prompt for image
---for example:
---inoremap <C-Q> <C-O>:lua require'zhihu.nvim'.input()<CR>
---@param opts table?
---@param prompt string?
function M.input(opts, prompt)
  opts = opts or {}
  prompt = prompt or 'Enter image file path: '
  vim.ui.input({
    prompt = prompt, completion = 'file'
  }, function(input)
    return M.on_confirm(opts.input, opts.src_type, opts.regnames, opts.max_retry, opts.sleep_seconds)
  end)
end

---callback for `input`
---@param input string
---@param src_type "src" | "original_src" | "watermark_src" | "animation_cover_src"?
---@param regnames string[]?
---@param max_retry integer?
---@param sleep_seconds integer?
function M.on_confirm(input, src_type, regnames, max_retry, sleep_seconds)
  if input == nil then
    return
  end
  regnames = regnames or { "+", "*" }
  if input:sub(1, 2) == '~/' then
    input = uv.os_homedir() .. '/' .. input:sub(3)
  end
  local Uploader = require 'zhihu.image'.Uploader
  local uploader = Uploader.from_file(input)
  local id = tostring(uploader)
  vim.notify(uploader.status, id == "" and vim.log.levels.ERROR, {
    title = "zhihu.nvim",
  })
  if id == "" then
    return
  end
  require 'zhihu.image'.fetch_image_async(id, max_retry, sleep_seconds, function(image)
    image.src_type = src_type or image.src_type
    local url = tostring(image)
    if url == "" then
      vim.notify(image.status, vim.log.levels.ERROR, {
        title = "zhihu.nvim",
      })
      return
    end
    for _, regname in ipairs(regnames) do
      if regname == "." then
        vim.api.nvim_put({ url }, "b", false, true)
      else
        vim.schedule(function()
          vim.fn.setreg(regname, url)
        end)
      end
    end
    vim.notify(image.status .. "copied to register " .. table.concat(regnames, ', '),
      vim.log.levels.INFO,
      {
        title = "zhihu.nvim",
      })
  end)
end

---open article's URL.
---for example:
---nnoremap <localleader>lv :lua require'zhihu.nvim'.open()<CR>
---@param id integer?
---@param question_id integer?
---@param edit boolean?
function M.open(id, question_id, edit)
  if not vim.bo.modifiable then
    edit = false
  end
  local article = { itemId = id, question_id = question_id }
  if article.itemId == nil and article.question_id == nil then
    article = vim.b.article
  end
  local Article = require 'zhihu.article'.Article
  article = Article(article)
  local url
  if article.itemId or article.question_id then
    url = article:get_url(edit)
  else
    url = vim.api.nvim_buf_get_name(0)
    if url:match "zhihu://" then
      vim.notify("run :w firstly!", vim.log.levels.WARN)
      return
    end
  end
  vim.ui.open(url)
end

return M
