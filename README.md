# [pug 语法](https://github.com/sveltejs/svelte-preprocess/blob/main/docs/preprocessing.md#pug)

You can check the [Pug API reference](https://pugjs.org/api/reference.html) for information about its options. The only overridden property is `doctype`, which is set to HTML.

Apart from those, the Pug preprocessor accepts:

| Option           | Default     | Description                                                                                                         |
| ---------------- | ----------- | ------------------------------------------------------------------------------------------------------------------- |
| `markupTagName`  | `template`  | the tag name used to look for the optional markup wrapper. If none is found, `pug` is executed over the whole file. |
| `configFilePath` | `undefined` | the path of the directory containing the PostCSS configuration.                                                     |

**Template blocks:**

Some of Svelte's template syntax is invalid in Pug. `svelte-preprocess` provides some pug mixins to represent svelte's `{#...}{/...}` blocks: `+if()`, `+else()`, `+elseif()`, `+each()`, `+key()`, `+await()`, `+then()`, `+catch()`, `+html()`, `+debug()`.

```pug
ul
  +if('posts && posts.length > 1')
    +each('posts as post')
      li
        a(rel="prefetch" href="blog/{post.slug}") {post.title}
    +else()
      span No posts :c
```

**Element attributes:**

Pug encodes everything inside an element attribute to html entities, so `attr="{foo && bar}"` becomes `attr="foo &amp;&amp; bar"`. To prevent this from happening, instead of using the `=` operator use `!=` which won't encode your attribute value:

```pug
button(disabled!="{foo && bar}")
```

This is also necessary to pass callbacks:

```pug
button(on:click!="{(e) => doTheThing(e)}")
```

It is not possible to use template literals for attribute values. You can't write `` attr=`Hello ${value ? 'Foo' : 'Bar'}` ``, instead write `attr="Hello {value ? 'Foo' : 'Bar'}"`.

**Spreading props:**

To spread props into a pug element, wrap the `{...object}` expression with quotes `"`.

This:

```pug
button.big(type="button" disabled "{...slide.props}") Send
```

Becomes:

```svelte
<button class="big" type="button" disabled {...slide.props}>
  Send
</button>
```

**Svelte Element directives:**

Syntax to use Svelte Element directives with Pug

```pug
input(bind:value="{foo}")
input(on:input="{bar}")
```
