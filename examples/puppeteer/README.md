# Puppeteer · Owl Light examples

```bash
# IMPORTANT: skip Puppeteer's bundled Chromium download — Owl Light *is*
# the browser you want to use.
PUPPETEER_SKIP_DOWNLOAD=true npm install

# in another terminal: start Owl Light
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147

# then run any example:
npm run basic
npm run screenshot
npm run login
```

| File | What it shows |
|---|---|
| [`01_basic.mjs`](01_basic.mjs) | `puppeteer.connect({ browserURL })`, navigate, log title |
| [`02_screenshot.mjs`](02_screenshot.mjs) | `fullPage: true` PNG of any URL |
| [`03_form_login.mjs`](03_form_login.mjs) | Type, click, assert post-login flash |
