"""02_screenshot.py — full-page screenshot of any URL.

Owl Light routes Playwright's full_page=True through a custom scroll-stitch
pipeline that handles SPA-style lazy-loaded sections, sticky navbars, and
infinite-scroll layouts correctly — no JS injection on your side.

Usage: python 02_screenshot.py [URL] [OUTPUT_PNG]
"""
import asyncio
import sys
from playwright.async_api import async_playwright


async def main(url: str, out: str):
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.set_viewport_size({"width": 1440, "height": 900})
        await page.goto(url, wait_until="networkidle", timeout=45000)
        png = await page.screenshot(full_page=True)
        with open(out, "wb") as f:
            f.write(png)
        print(f"wrote {len(png):,} bytes to {out}")
        await browser.close()


if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else "https://www.owlbrowser.net"
    out = sys.argv[2] if len(sys.argv) > 2 else "screenshot.png"
    asyncio.run(main(url, out))
