"""01_basic.py — connect to a running Owl Light, navigate, read title.

Prereq: in another terminal,
    owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147
"""
import asyncio
from playwright.async_api import async_playwright


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.goto("https://example.com", wait_until="domcontentloaded")
        title = await page.title()
        print(f"title: {title!r}")
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
