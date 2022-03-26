import puppeteer from "puppeteer"

class Chrome
  constructor:(@browser)->

  get:(url)->
    page = null
    html = false
    page = await @browser.newPage()
    try
      await page.goto url, waitUntil: 'networkidle0'
      return await page.content()
    catch e
      console.error e
      console.error url
      return
    finally
      await page.close()
    return

export default new Chrome await puppeteer.launch(args: [ '--no-sandbox' ])
