#!/usr/bin/env coffee

import chrome from './chrome'
import thisdir from '@rmw/thisdir'
import static_serve from 'koa-static'
import Koa from 'koa'
import {dirname,join} from 'path'
import fs from 'fs'

PWD = thisdir import.meta
ROOT = dirname PWD
HTM = join PWD, 'htm'

mkdir = (fp)->
  fs.mkdirSync(dirname(fp), { recursive: true })
  return

koa = new Koa()

koa.use(static_serve join(ROOT,'web/dist'), index:'index.htm')

{address,port} = await new Promise (resolve)=>
  koa.listen(0,'127.0.0.1').on(
    'listening'
    ->
      resolve @address()
      return
  )

HTTP = "http://#{address}:#{port}"

console.log HTTP

URL_LI = [
  ''
]

do =>
  for url from URL_LI
    html = await chrome.get(HTTP+url)
    if not html
      continue
    fp = join HTM, (url or 'index')+'.htm'
    await mkdir fp
    fs.writeFileSync fp,html

  process.exit()
  return
