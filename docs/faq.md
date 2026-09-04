# FAQ

### Is Owl Light a fork of Chromium?

Yes. Owl Light is built from a custom Chromium tree with ~50 patches
applied on top of the upstream source. The patches add fingerprint
virtualization at the source level (canvas, WebGL, audio, navigator,
client hints, fonts, etc.) and a small CDP-domain extension. The Chromium
core, V8, Blink, and the entire web platform are otherwise stock.

### Why not just use puppeteer-extra-plugin-stealth?

Stealth plugins inject JavaScript into every page that overrides browser
APIs at runtime. That has three problems:

1. **Inspectable.** `navigator.userAgent.toString.toString()`,
   prototype-chain enumeration, and `Object.getOwnPropertyDescriptor(...)`
   reveal the override layer. Modern detectors (Cloudflare, DataDome,
   fingerprint.com) check for these.
2. **Late.** Patches load after the page's first execution context, so
   any code that runs *before* the patch sees unspoofed values.
3. **Incomplete.** Service Workers, dedicated/shared workers, isolated
   worlds, and out-of-process iframes don't get the patches.

Owl Light spoofs at the C++ Blink/V8 layer. The spoofed values *are* the
values, so there is no patching layer to detect, and the spoofs apply
uniformly across every execution context the renderer creates.

### Does it work with Selenium / WebDriver?

Owl Light is CDP-only. Selenium WebDriver protocol is not exposed.
Use Selenium 4's CDP support, or migrate to Playwright/Puppeteer.

### Does this work with Playwright's `chromium.launch()`?

Not yet. Use CDP mode instead: start Owl Light yourself and connect to it.

```bash
owl-light --headless=new --remote-debugging-port=9222 --user-data-dir=/tmp/owl
```

```python
browser = playwright.chromium.connect_over_cdp("http://localhost:9222")
```

```js
const browser = await puppeteer.connect({ browserURL: "http://localhost:9222" });
```

`chromium.launch(executable_path=...)` and `puppeteer.launch()` fail with
`Cannot read properties of undefined (reading '_page')`. Both create a browser
context and then a page inside it, but Owl Light creates every page in its
default context regardless of the `browserContextId` requested, so the client
never matches the page to the context it asked for. CDP mode avoids this
because it adopts the existing default context instead of creating one.

CDP mode is also the better choice for production: one Owl Light instance can
serve many test runs.

### A client connects but the handshake never finishes

Check that only one instance holds the port:

```bash
lsof -nP -iTCP:9222 -sTCP:LISTEN
```

Two listeners, typically a stale process on IPv4 and a newer one on IPv6, give
exactly that symptom: `/json/version` answers from one process while the client
hangs against the other.

### Is the binary signed / notarized on macOS?

Yes. The macOS arm64 build is signed with a **Developer ID Application**
certificate (Olib AI LLC), **notarized by Apple, and stapled**, so it
launches without a Gatekeeper prompt and works offline. Verify it yourself:

```bash
spctl -a -vv /path/to/owl_light.app     # => source=Notarized Developer ID
xcrun stapler validate /path/to/owl_light.app
```

If you ever do see a "can't verify the developer" warning, the download lost
its stapled ticket (some tools strip extended attributes). Clear the quarantine
flag and reopen:

```bash
xattr -dr com.apple.quarantine /path/to/owl_light.app
```

The **Windows** build is not yet signed with an EV code-signing certificate, so
SmartScreen may warn on first run.

### Is there a Windows build?

Owl Light publishes macOS (arm64) and Linux (amd64 + arm64) only. Windows
support is part of [Owl Browser Enterprise](enterprise.md). Open an issue
if you need it on Owl Light specifically.

### How do I update?

Re-run the installer:

```bash
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh
```

It overwrites the install in place.

### What's the difference between Owl Light and Owl Browser Enterprise?

Owl Light is the open distribution of the stealth Chromium engine, one
binary, drop-in CDP, 150 bundled fingerprint profiles. Owl Browser
Enterprise adds the full automation platform on top: 256 isolated browser
contexts per process, Tor integration, residential proxy management,
175+ automation tools (REST + WebSocket + MCP), an on-device vision LLM
for page understanding and CAPTCHA solving, video recording, audit
logging, SOC2 hardening, and dedicated support. See
[enterprise.md](enterprise.md).

### Does Owl Light send any telemetry?

No. The binary makes no outbound connections at startup, and there is no
crash-reporting or analytics. The only network traffic is what your test
code drives.

### How big are the releases?

| Platform | Compressed | Uncompressed |
|---|---|---|
| macOS arm64  | ~165 MB | ~750 MB |
| Linux amd64  | ~198 MB | ~770 MB |
| Linux arm64  | ~193 MB | ~810 MB |

Most of the size is CEF / Chromium itself (libcef.so + V8 snapshot +
Resources/) plus a small bundle of OSS fonts.

### Where do I report bugs?

[github.com/Olib-AI/owl-light/issues](https://github.com/Olib-AI/owl-light/issues).

For commercial questions: [sales@olib.ai](mailto:sales@olib.ai).
