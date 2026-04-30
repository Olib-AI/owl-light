// 01_basic.mjs — connect, navigate, log title.
import { chromium } from 'playwright';

const browser = await chromium.connectOverCDP('http://localhost:9222');
const page = browser.contexts()[0].pages()[0];
await page.goto('https://example.com', { waitUntil: 'domcontentloaded' });
console.log('title:', await page.title());
await browser.close();
