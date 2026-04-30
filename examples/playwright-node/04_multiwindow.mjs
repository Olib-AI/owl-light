// 04_multiwindow.mjs — clicking target=_blank surfaces a new Page.
import { chromium } from 'playwright';

const browser = await chromium.connectOverCDP('http://localhost:9222');
const ctx = browser.contexts()[0];
const page = ctx.pages()[0];
await page.goto('https://the-internet.herokuapp.com/windows');

const newPagePromise = ctx.waitForEvent('page');
await page.click('a[href="/windows/new"]');
const newPage = await newPagePromise;
await newPage.waitForLoadState('domcontentloaded');
const h3 = await newPage.locator('h3').innerText();
console.log(`new tab url=${newPage.url()}  h3=${JSON.stringify(h3)}`);
if (h3 !== 'New Window') throw new Error(`unexpected h3: ${h3}`);
await newPage.close();
await browser.close();
