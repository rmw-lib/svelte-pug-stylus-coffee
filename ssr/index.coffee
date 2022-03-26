#!/usr/bin/env coffee

import fsline from '@rmw/fsline'
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

do =>
  for await url from fsline(join(PWD,'url.txt'))
    console.log '→',url
    html = await chrome.get(HTTP+url)
    if not html
      continue
    fp = join HTM, (url or 'index')+'.htm'
    await mkdir fp
    fs.writeFileSync fp,html

  process.exit()
  return
