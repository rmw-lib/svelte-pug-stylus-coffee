#!/usr/bin/env coffee

import thisdir from '@rmw/thisdir'
import static_serve from 'koa-static'
import Koa from 'koa'
import {dirname,join} from 'path'

ROOT = dirname thisdir import.meta

koa = new Koa()

koa.use(static_serve join(ROOT,'web/dist'), index:'index.htm')

{address,port} = await new Promise (resolve)=>
  koa.listen(0,'127.0.0.1').on(
    'listening'
    ->
      resolve @address()
      return
  )

console.log "http://#{address}:#{port}"

###
import prerender from 'prerender'
server = prerender()
server.start()
###
