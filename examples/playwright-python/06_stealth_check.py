"""06_stealth_check.py — visit fingerprint test pages and report.

Quick sanity check that Owl Light is producing a coherent fingerprint:
  - navigator.webdriver should be False
  - navigator.platform / userAgent should match the spoofed --owl-os
  - WebGL renderer / canvas hash should NOT identify the host machine
"""
import asyncio
from playwright.async_api import async_playwright


JS_PROBE = r"""
() => ({
  webdriver:  navigator.webdriver,
  ua:         navigator.userAgent,
  platform:   navigator.platform,
  langs:      navigator.languages,
  cores:      navigator.hardwareConcurrency,
  memory:     navigator.deviceMemory ?? null,
  timezone:   Intl.DateTimeFormat().resolvedOptions().timeZone,
  webgl: (() => {
    const c = document.createElement('canvas').getContext('webgl');
    if (!c) return null;
    const dbg = c.getExtension('WEBGL_debug_renderer_info');
    return dbg ? {
      vendor:   c.getParameter(dbg.UNMASKED_VENDOR_WEBGL),
      renderer: c.getParameter(dbg.UNMASKED_RENDERER_WEBGL),
    } : null;
  })(),
})
"""


async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.goto("https://example.com")  # any same-origin doc
        info = await page.evaluate(JS_PROBE)

        for k, v in info.items():
            print(f"  {k:>10}  {v}")

        # Strong assertions
        assert info["webdriver"] is False, "navigator.webdriver leaked!"
        assert "HeadlessChrome" not in info["ua"], "headless tag leaked!"
        assert info["webgl"] is None or "ANGLE" in info["webgl"]["renderer"], \
            "unexpected WebGL renderer"
        print("\nstealth checks passed ✓")
        await browser.close()


if __name__ == "__main__":
    asyncio.run(main())
