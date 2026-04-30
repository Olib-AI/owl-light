// 02_screenshot.mjs — full-page PNG of any URL.
// usage: node 02_screenshot.mjs [URL] [OUT]
import puppeteer from 'puppeteer';
import { writeFileSync } from 'node:fs';

const url = process.argv[2] ?? 'https://www.owlbrowser.net';
const out = process.argv[3] ?? 'screenshot.png';

const browser = await puppeteer.connect({ browserURL: 'http://localhost:9222' });
const pages = await browser.pages();
const page = pages[0] ?? (await browser.newPage());
await page.setViewport({ width: 1440, height: 900 });
await page.goto(url, { waitUntil: 'networkidle2', timeout: 45000 });
const png = await page.screenshot({ fullPage: true, encoding: 'binary' });
writeFileSync(out, png);
console.log(`wrote ${png.length.toLocaleString()} bytes to ${out}`);
await browser.disconnect();
