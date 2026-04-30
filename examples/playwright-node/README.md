# Playwright + Node.js · Owl Light examples

```bash
npm install
# in another terminal: start Owl Light
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147
# then:
npm run basic
npm run screenshot
npm run login
npm run windows
```

| File | What it shows |
|---|---|
| [`01_basic.mjs`](01_basic.mjs) | Connect over CDP, navigate, read title |
| [`02_screenshot.mjs`](02_screenshot.mjs) | Full-page PNG of any URL |
| [`03_form_login.mjs`](03_form_login.mjs) | Fill, submit, assert flash message |
| [`04_multiwindow.mjs`](04_multiwindow.mjs) | Drive a popup opened via `target=_blank` |
