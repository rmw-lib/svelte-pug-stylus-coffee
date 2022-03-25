#!/usr/bin/env coffee

import thisdir from '@rmw/thisdir'
import {Readable} from 'stream'
import mime from 'mime-types'
import {createHash} from 'crypto'
import {SITE,QINIU_BUCKET} from '../config/qiniu'
import Qiniu from '@rmw/qiniu'
import {join,dirname} from 'path'
import {walkRel} from '@rmw/walk'
import {createReadStream,statSync,readFileSync,writeFileSync,renameSync} from 'fs'
import { open } from 'lmdbx'
import Base from 'base-p'
BASE = new Base('/-_~()*0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')

PWD = thisdir import.meta
ROOT = dirname PWD
DIST = join ROOT, 'dist'
PATH_ID = join PWD,'.id'

index_htm = 'index.htm'
renameSync join(DIST,index_htm+'l'),join(DIST,index_htm)

try
  ID = JSON.parse readFileSync(PATH_ID,'utf8')
catch err
  ID = -1

extname = (file)=>
  ext = file.lastIndexOf('.')+1
  if ext
    return file[ext..]

sha3 = (path) =>
  h = createHash('sha3-256')
  stream = createReadStream(path)
  stream.on 'data', h.update.bind(h)

  new Promise (resolve, reject) =>
    stream.on 'error', reject
    stream.on 'end', => resolve h.digest()
    return

HashName = DB = open join PWD,'.uploaded'
NameHash = DB.openDB 'NameHash'

QINIU = Qiniu()

PUBLIC = new Set [ index_htm ]
await do =>
  for await name from walkRel join(ROOT,'public')
    PUBLIC.add name
  return

UPLOADED = []
HTTP = 'https://'+SITE+'/'


NAME_ID = []

EXT = new Set 'js css html'.split ' '

stream = (file)=>
  console.log file
  ext = extname file
  if EXT.has ext
    s = new Readable()
    txt = readFileSync file,'utf8'
    for [name, id] from NAME_ID
      txt = txt.split(name).join('.'+BASE.encode(id))
    if ~file.indexOf('htm')
      console.log txt
    s.push(txt)
    s.push(null)
    return s
  else
    return createReadStream(file)

upload = (name, read=stream,extra={})=>
  console.log HTTP+name
  UPLOADED.push name
  QINIU.upload_file(
    QINIU_BUCKET
    DIST
    name
    read
    extra
  )

TO_UPLOAD = []

await do =>
  for await name from walkRel join DIST
    if PUBLIC.has name
      continue

    id = HashName.get name

    if id != undefined
      NAME_ID.push [name,id]
      continue

    loop
      if not BASE.encode(++ID).endsWith '/'
        break

    li = [name,ID]
    NAME_ID.push li
    TO_UPLOAD.push li

  TO_UPLOAD.sort (a,b)=>a[1]-b[1]
  await writeFileSync PATH_ID, JSON.stringify ID
  return

upload_public = (name)=>
  fp = join DIST, name
  hash = await sha3(fp)
  pre = NameHash.get(name)
  if pre and Buffer.compare(hash,pre) == 0
    continue
  await upload name
  await NameHash.put(name,hash)
  return

await do =>
  for [name, id] from TO_UPLOAD
    ext = extname(name)
    extra = {}
    if ext
      mimeType = mime.lookup ext
      if mimeType
        extra.mimeType = mimeType
    await upload(
      '.'+BASE.encode(id)
      =>
        stream join(DIST,name)
      extra
    )
    await HashName.put name, id

  PUBLIC.remove index_htm
  for name from PUBLIC
    await upload_public(name)
  await upload_public index_htm
  return

DB.close()
await QINIU.refresh SITE, UPLOADED
process.exit()
