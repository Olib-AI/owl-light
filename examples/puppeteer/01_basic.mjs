// 01_basic.mjs — connect to Owl Light over CDP, navigate, log title.
import puppeteer from 'puppeteer';

const browser = await puppeteer.connect({ browserURL: 'http://localhost:9222' });
const pages = await browser.pages();
const page = pages[0] ?? (await browser.newPage());
await page.goto('https://example.com', { waitUntil: 'domcontentloaded' });
console.log('title:', await page.title());
await browser.disconnect();
