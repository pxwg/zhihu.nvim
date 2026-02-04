# Zhihu on Neovim

[Zhihu](https://www.zhihu.com/) extension built on [NeoVim](https://github.com/neovim/neovim).

[中文文档](https://zhuanlan.zhihu.com/p/1998903214075027613)

## Features

- [x] Convert local markdown files into Zhihu articles and send them to the draft box;
- [x] Using user-defined scripts to convert other file types into Zhihu articles, then upload them to the draft box.
- [x] Synchronizing Zhihu articles to local markdown files;
- [ ] Support editing Zhihu answers;
- [ ] Support direct publishing of Zhihu articles and answers (bypassing the draft box);
- [ ] Add [blink-cmp](https://github.com/Saghen/blink.cmp) to auto complete @(user name list) and # tags (c.f.: [zhihu_obsidian](https://github.com/dongguaguaguagua/zhihu_obsidian)).
- [ ] Develop and test a more robust conversion library to achieve 100% compatibility with Zhihu-flavored HTML.

## Installation

### rocks.nvim

#### Command style

```vim
:Rocks install zhihu.nvim
```

#### Declare style

`~/.config/nvim/rocks.toml`:

```toml
[plugins]
"zhihu.nvim" = "scm"
```

Then

```vim
:Rocks sync
```

or:

```sh
$ luarocks --lua-version 5.1 --local --tree ~/.local/share/nvim/rocks install zhihu.nvim
# ~/.local/share/nvim/rocks is the default rocks tree path
# you can change it according to your vim.g.rocks_nvim.rocks_path
```

### lazy.nvim

```lua
return {
  "pxwg/zhihu.nvim",
  main = "zhihu",
  config = function()
    require("zhihu").setup({
      -- Optional: configure custom filetypes
      filetypes = {
        typst = {
          type = "markdown_to_html",
          converter = function(content) return content end
        }
      }
    })
  end
}
```

## Usage

### Setup (Optional)

You can provide custom file type handlers in the setup function:

```lua
require("zhihu").setup({
  filetypes = {
    typst = {
      -- Two conversion strategies:
      -- 1. "markdown_to_html": Convert to markdown first, then to HTML
      type = "markdown_to_html",
      ---Required: function to convert your format to markdown
      ---@param content string Your file content from buffer
      ---@return string markdown content output, used to generate HTML
      converter = function(content)
        return require("my_converters").typst_to_markdown(content)
      end
    },
    rst = {
      -- 2. "direct_html": Convert directly to HTML
      -- This way is NOT recommended unless you have a robust converter which can generate Zhihu-compatible HTML content, which is VERY hard to implement and nearly NO existing libraries can do this well.
      type = "direct_html",
      ---Required: function to convert your format directly to HTML
      ---@param content string Your file content from buffer
      direct_converter = function(content)
        return require("my_converters").rst_to_html(content)
      end
    }
  }
})
```

See `lua/zhihu/examples/setup_example.lua` for a full example.

### Zhihu Article

```sh
vi zhihu://XXX.md
# or
vi zhihu://XXX.html
```

or in neovim:

```vim
:edit zhihu://XXX.md
```

The article whose id is XXX will be opened.
After editing,

```vim
:write
```

will save the article to draft.

```vim
:write
```

again will upload draft.

```vim
:nnoremap <localleader>lv :lua require'zhihu.article'.open()<CR>
```

Press `<localleader>lv` to view the article in your browser.

If you want to create an article from a default template, try:

```vim
:edit zhihu://new.md
:let b:article.title = "Title"
:write
```

```markdown
> 本文使用 [Zhihu on NeoVim](https://github.com/pxwg/zhihu.nvim) 创作并发布
```

If you try to open a non-existent article, you will see:

```vim
:edit zhihu://0.md
```

```markdown
# 404

你似乎来到了没有知识存在的荒原

[去往首页](https://www.zhihu.com)
```

### Zhihu Auth

In order to log in zhihu, this library search

- firefox cookies database
- chrome cookies database
- pychrome: a python module to communicate with chrome browser.
  open <https://www.zhihu.com/> to let user to log in

A cookies will be cached. If you meet `403 Forbidden`, try:

1. quit browser: avoid browser lock cookies database
2. restart neovim: fetch latest cookies from browser cookies database

If it doesn't work, try:

1. log in zhihu again: update cookies of browser cookies database
2. quit browser
3. restart neovim

### Zhihu Image

Every image must be on zhihu like
<https://picx.zhimg.com/v2-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>.

```vim
:let b:article.titleImage = "https://picx.zhimg.com/v2-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
```

## API

### Update zhihu article

You can update zhihu article by:

```lua
local Article = require 'zhihu.article.markdown'.Article
-- or if your prefer using HTML to write article
-- local Article = require 'zhihu.article.html'.Article
local id = "your_article_id"
local article
if id then
  article = Article:from_id(id)
  -- or create an article
else
  article = Article { title = "title" }
end
local f = io.open "/the/path/of/your/article.md"
if f then
  local markdown = f:read "*a"
  f:close()
  article:set_content(markdown)
  article:update()
end
```

### Upload image to zhihu

```lua
local Image = require 'zhihu.image'.Image
local image = Image.from_file "/the/path/of/image.png"
print(image)
-- https://picx.zhimg.com/v2-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### Convert markdown and HTML

```lua
local md_to_html = require 'markdown_to_html'.md_to_html
local html_to_md = function(html)
    return require 'zhihu.article.generator.markdown'.generator:translate(html)
end
local markdown = "# Title"
assert(markdown == html_to_md(md_to_html(markdown)))
```

## Similar Projects

- [zhihu_obsidian](https://github.com/dongguaguaguagua/zhihu_obsidian)
- [VSCode-Zhihu](https://github.com/niudai/VSCode-Zhihu)

## Related Projects

- [md2zhihu](https://github.com/drmingdrmer/md2zhihu): convert markdown to zhihu markdown
