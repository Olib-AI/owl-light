"""04_multiwindow.py — clicking a target=_blank link surfaces a new Page.

Owl Light wires CEF's popup lifecycle into Playwright's auto-attach so
context.expect_page() resolves correctly for window.open / target=_blank.
"""
import asyncio
from playwright.async_api import async_playwright


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        ctx = browser.contexts[0]
        page = ctx.pages[0]
        await page.goto("https://the-internet.herokuapp.com/windows")

        async with ctx.expect_page() as info:
            await page.click('a[href="/windows/new"]')
        new_page = await info.value

        await new_page.wait_for_load_state("domcontentloaded")
        h3 = await new_page.locator("h3").inner_text()
        print(f"new tab url={new_page.url}  h3={h3!r}")
        assert h3 == "New Window"
        await new_page.close()
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
