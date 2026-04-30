"""03_form_login.py — fill a login form, submit, assert success.

Uses the public the-internet.herokuapp.com test site so this works without
any credentials of your own.
"""
import asyncio
from playwright.async_api import async_playwright


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.goto("https://the-internet.herokuapp.com/login")
        await page.fill("#username", "tomsmith")
        await page.fill("#password", "SuperSecretPassword!")
        async with page.expect_navigation():
            await page.click('button[type="submit"]')
        flash = await page.locator("#flash.success").inner_text()
        assert "logged into a secure area" in flash, f"unexpected flash: {flash!r}"
        print("login ok ✓")
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
