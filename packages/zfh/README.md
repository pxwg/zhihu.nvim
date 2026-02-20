# zfh

<https://www.zhihu.com/api/v4/content/publish> uses a various HTML standard.
So we need a specification for it.

## Spec

We only record the difference from [standard HTML](https://html.spec.whatwg.org/multipage/).
You can use [pandoc](https://pandoc.org/) to generate standard HTML from
markdown.

### Fenced code blocks

```python
x = True if 2 > 1 else False
```

``````markdown
```python
x = True if 2 > 1 else False
```
``````

```html
<div class="sourceCode" id="cb1">
<pre class="sourceCode python">
<code class="sourceCode python">
<span id="cb1-1"><a href="#cb1-1" aria-hidden="true" tabindex="-1"></a>
x <span class="op">=</span>
<span class="va">True</span> <span class="cf">if</span>
<span class="dv">2</span> <span class="op">&gt;</span> <span class="dv">1</span>
<span class="cf">else</span> <span class="va">False</span>
</span>
</code>
</pre>
</div>
```

```html
<pre lang="python">x = True if 2 &gt; 1 else False</pre>
```

### Images

![caption](https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c "title")

```markdown
![caption](https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c "title")
```

```html
<figure>
<img src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
title="title" alt="caption" />
<figcaption aria-hidden="true">caption</figcaption>
</figure>
```

```html
<img src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
data-caption="caption" data-size="normal" data-watermark="watermark"
data-original-src="https://pica.zhimg.com/80/v2-91c9434b826e4e271820b84637c0856c"
data-watermark-src="" data-private-watermark-src="">
```

### Inline math

$\alpha_1$

```markdown
$\alpha_1$
```

```html
<span class="math inline"><em>α</em><sub>1</sub></span>
```

```html
<img eeimg="1" src="//www.zhihu.com/equation?tex=\alpha_1" alt="\alpha_1">
```

### Display math

$$\alpha_1$$

```markdown
$$\alpha_1$$
```

```html
<p><span class="math display"><em>α</em><sub>1</sub></span></p>
```

```html
<p><img eeimg="1" src="//www.zhihu.com/equation?tex=\alpha_1" alt="\alpha_1"></p>
```

### Footnote

text[^1]

[^1]: footnote

```markdown
text[^1]

[^1]: footnote
```

```html
<p>text<a href="#fn1" class="footnote-ref" id="fnref1"
role="doc-noteref"><sup>1</sup></a></p>
<section id="footnotes" class="footnotes footnotes-end-of-document" role="doc-endnotes">
<hr />
<ol>
<li id="fn1"><p>footnote<a href="#fnref1" class="footnote-back"
role="doc-backlink">↩︎</a></p></li>
</ol>
</section>
```

```html
<p>text<sup class="footnote-reference"><a href="#1">1</a></sup></p>
<div class="footnote-definition" id="1"><sup class="footnote-definition-label">1</sup><p>footnote</p></div>
```

## Usage

This project provide a library to convert many markup languages to Zhihu
flavored HTML.

```lua
local text = "$\alpha_1$"
local md_to_html = require'markdown_to_html'.md_to_html
print(md_to_html(text))
```

## Related Projects

- [Github flavored markdown](https://github.github.com/gfm/)
