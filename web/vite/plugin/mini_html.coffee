import {minify} from 'html-minifier-terser'

export INDEX_HTML = 'index.html'

export default {
  name: 'mini_html'
  apply: 'build'
  enforce: 'post'
  generateBundle : (_,bundle)=>
    for i from Object.values bundle
      if i.type == 'asset' and /\.html?$/.test(i.fileName)
        if INDEX_HTML == i.fileName
          i.fileName = INDEX_HTML[...-1]
        i.source = await minify i.source,{
          collapseWhitespace: true
          html5: true
          minifyCSS: true
          minifyJS: true
          removeAttributeQuotes: true
          removeComments: true
          removeRedundantAttributes: true
          removeScriptTypeAttributes: true
          removeStyleLinkTypeAttributes: true
          useShortDoctype: true
        }
    return
}
