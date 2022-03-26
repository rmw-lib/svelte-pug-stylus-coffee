import { join,dirname } from 'path'
import sveltePreprocess from '@rmw/svelte-preprocess'
import htmlMinimizeMod from '@sergeymakinen/vite-plugin-html-minimize'
htmlMinimize = htmlMinimizeMod.default
import { merge } from 'lodash-es'
import vitePluginStylusAlias from './plugin/vite-plugin-stylus-alias.mjs'
import coffee from '@rmw/rollup-plugin-coffee'
import pug from 'pug'
import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'
import thisdir from '@rmw/thisdir'
import { writeFileSync,renameSync } from 'fs'
import import_pug from './plugin/pug.js'

ROOT = dirname thisdir(import.meta)
DIST = join ROOT,'dist'
SRC = join ROOT,'src'
PRODUCTION = process.env.NODE_ENV == 'production'

INDEX_HTML = 'index.html'
SRC_INDEX_HTML = join SRC,INDEX_HTML
writeFileSync(
  SRC_INDEX_HTML
  pug.compileFile(join SRC, 'index.pug')({
  })
)
host = '0.0.0.0' or env.VITE_HOST
port = 5001 or env.VITE_PORT

config = {
  plugins: [
    coffee(
      bare:true
      sourceMap:true
    )
    svelte(
      preprocess: [
        sveltePreprocess(
          coffeescript: {
            sourceMap: true
          }
          stylus: true
          pug: true
        )
      ]
    )
    vitePluginStylusAlias()
    import_pug()
  ]
  clearScreen: false
  server:{
    host
    port
    proxy:
      '^/[^@.]+$':
        target: "http://#{host}:#{port}"
        rewrite: (path)=>'/'
        changeOrigin: false
  }
  resolve:
    alias:
      ":": join(ROOT, "file")
      '~': SRC
  esbuild:
    legalComments: 'none'
    treeShaking: true
  root: SRC
  build:
    outDir: DIST
    rollupOptions:
      input:
        index:SRC_INDEX_HTML
    target:['edge90','chrome90','firefox90','safari15']
    assetsDir: '/'
    emptyOutDir: true
}

if PRODUCTION
  FILENAME = '[name].[hash].[ext]'
  JSNAME = '[name].[hash].js'
  minimize = htmlMinimize({
    filter: /\.html?$/,
  })
  {generateBundle} = minimize
  minimize.generateBundle = (_,bundle)=>
    for i from Object.values bundle
      if INDEX_HTML == i.fileName
        i.fileName = INDEX_HTML[...-1]
    generateBundle(_,bundle)

  config = merge config,{
    plugins:[
      minimize
    ]
    base: '/'
    build:
      rollupOptions:
        output:
          chunkFileNames: JSNAME
          assetFileNames: FILENAME
          entryFileNames: JSNAME
  }
export default =>
  defineConfig config
