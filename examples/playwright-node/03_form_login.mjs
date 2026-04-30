// 03_form_login.mjs — fill, submit, assert.
import { chromium } from 'playwright';

const browser = await chromium.connectOverCDP('http://localhost:9222');
const page = browser.contexts()[0].pages()[0];
await page.goto('https://the-internet.herokuapp.com/login');
await page.fill('#username', 'tomsmith');
await page.fill('#password', 'SuperSecretPassword!');
await Promise.all([
  page.waitForNavigation(),
  page.click('button[type="submit"]'),
]);
const flash = await page.locator('#flash.success').innerText();
if (!flash.includes('logged into a secure area')) {
  throw new Error(`unexpected flash: ${JSON.stringify(flash)}`);
}
console.log('login ok ✓');
await browser.close();
