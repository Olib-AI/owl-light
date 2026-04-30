// 03_form_login.mjs — fill a form, submit, assert success message.
import puppeteer from 'puppeteer';

const browser = await puppeteer.connect({ browserURL: 'http://localhost:9222' });
const pages = await browser.pages();
const page = pages[0] ?? (await browser.newPage());
await page.goto('https://the-internet.herokuapp.com/login', { waitUntil: 'domcontentloaded' });
await page.type('#username', 'tomsmith');
await page.type('#password', 'SuperSecretPassword!');
await Promise.all([
  page.waitForNavigation(),
  page.click('button[type="submit"]'),
]);
const flash = await page.$eval('#flash.success', el => el.innerText);
if (!flash.includes('logged into a secure area')) {
  throw new Error(`unexpected flash: ${JSON.stringify(flash)}`);
}
console.log('login ok ✓');
await browser.disconnect();
