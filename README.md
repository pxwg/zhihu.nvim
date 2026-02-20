# Zhihu on Neovim

[Zhihu](https://www.zhihu.com/) extension built on [NeoVim](https://github.com/neovim/neovim).

[中文文档](https://zhuanlan.zhihu.com/p/1998903214075027613)

## Features

- [x] Synchronizing Zhihu articles to local markdown files;
- [x] Convert local markdown files into Zhihu articles and send them to the draft box;
- [x] Support direct publishing of Zhihu articles and answers (bypassing the draft box);
- [x] Using user-defined scripts to convert other file types into Zhihu articles
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
}
```

## Usage

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

will publish it.

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

### Zhihu Answer

Similar with article.

```sh
vi zhihu://question_id/new.md
```

### Zhihu Auth

See [auth](/packages/auth).

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
