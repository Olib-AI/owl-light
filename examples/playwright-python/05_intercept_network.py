"""05_intercept_network.py — block ads + rewrite a response.

Standard Playwright route() interception works exactly as you'd expect. No
Owl-specific config needed.
"""
import asyncio
from playwright.async_api import async_playwright


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]

        # Block any request matching "*ads*" or "*tracking*"
        await page.route(
            lambda url: "ads" in url or "tracking" in url,
            lambda route: route.abort()
        )

        # Rewrite a specific endpoint to return synthetic JSON
        async def fake_api(route):
            if route.request.url.endswith("/api/me"):
                await route.fulfill(
                    status=200, content_type="application/json",
                    body='{"id":42,"name":"Owlbert"}'
                )
            else:
                await route.continue_()
        await page.route("**/api/**", fake_api)

        await page.goto("https://www.olib.ai")
        print("navigated; ads blocked, /api/me mocked")
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
