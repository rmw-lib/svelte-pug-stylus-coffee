import puppeteer from "puppeteer"

class Chrome
  constructor:(@browser)->

  get:(url)->
    page = await @browser.newPage()
    try
      return await @_get(page,url)
    catch e
      console.error e
      console.error url
    finally
      await page.close()
    return

  _get:(page,url)->
    await page.goto url, waitUntil: 'networkidle0'
    return page.content()

export default new Chrome await puppeteer.launch(args: [ '--no-sandbox' ])
