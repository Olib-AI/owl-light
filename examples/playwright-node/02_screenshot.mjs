// 02_screenshot.mjs — full-page PNG of any URL.
// usage: node 02_screenshot.mjs [URL] [OUT]
import { chromium } from 'playwright';

const url = process.argv[2] ?? 'https://www.owlbrowser.net';
const out = process.argv[3] ?? 'screenshot.png';

const browser = await chromium.connectOverCDP('http://localhost:9222');
const page = browser.contexts()[0].pages()[0];
await page.setViewportSize({ width: 1440, height: 900 });
await page.goto(url, { waitUntil: 'networkidle', timeout: 45000 });
const png = await page.screenshot({ fullPage: true, path: out });
console.log(`wrote ${png.length.toLocaleString()} bytes to ${out}`);
await browser.close();
