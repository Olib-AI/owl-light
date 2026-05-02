<div align="center">
  <img src="web/assets/owl-logo.svg" alt="Owl Light" width="128" height="128"/>

  # Owl Light

  **A drop-in stealth Chromium for Playwright & Puppeteer.**
  No proxies. No JavaScript injection. Real spoofing, baked at the source.

  [![Latest release](https://img.shields.io/github/v/release/Olib-AI/owl-light?label=download&style=flat-square&color=4E9179)](https://github.com/Olib-AI/owl-light/releases/latest)
  [![Platforms](https://img.shields.io/badge/platforms-macOS%20arm64%20%7C%20Linux%20amd64%20%7C%20Linux%20arm64%20%7C%20Windows%20amd64-4E9179?style=flat-square)](https://github.com/Olib-AI/owl-light/releases)
  [![License](https://img.shields.io/badge/license-MIT-9EBE8F?style=flat-square)](LICENSE)
  [![Docs](https://img.shields.io/badge/docs-owlbrowser.net-4E9179?style=flat-square)](https://www.owlbrowser.net)

  [Quick start](#quick-start) · [Examples](examples/) · [Docs](docs/) · [Enterprise](#enterprise) · [owlbrowser.net](https://www.owlbrowser.net)
</div>

---

## What is Owl Light?

Owl Light is a single binary you run instead of plain Chromium when you need
to drive a real browser from **Playwright** or **Puppeteer** — but you want
the page to look like a regular user, not a headless bot.

It's a custom Chromium build with hardware-level fingerprint virtualization
compiled directly into the engine: GPU, canvas, WebGL, audio, fonts, navigator,
`Sec-CH-UA-*` headers, timezone, locale, and more. The spoofed values come
from the same Blink code paths as real ones, so JavaScript introspection,
`toString()` checks, and prototype-chain audits all see authentic values.

It speaks vanilla CDP. Your existing `connect_over_cdp(...)` /
`puppeteer.connect({ browserURL })` code keeps working — point it at
`http://localhost:9222` and you're done.

```bash
# 1. download for your platform
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh

# 2. run
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147

# 3. drive it from your existing test
```

```python
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.goto("https://example.com")
        print(await page.title())

asyncio.run(main())
```

That's it. No SDK, no client library — just the Chrome DevTools Protocol you
already speak.

---

## Why?

| | Plain Chromium / Playwright | **Owl Light** |
|---|---|---|
| Fingerprint | Identical to every other Playwright user | 15 bundled VM profiles (Windows, macOS, Linux × Chrome 143–147), each with a fully self-consistent identity |
| Detection by Cloudflare / DataDome / fingerprint.com | Frequently flagged as bot | Passes |
| `navigator.webdriver` | `true` | `undefined` (and so is every other tell) |
| GPU / canvas / WebGL | Real machine — leaks identity | Virtualized at the C++ source level |
| Setup | Brittle stealth plugins, monkey-patched at runtime | One binary, zero JS injection |
| Compatible with | Playwright, Puppeteer | **Same.** Drop-in, no API changes |

---

## Platforms

Pre-built binaries for:

- **macOS arm64** — Apple Silicon (`.app` bundle, ~232 MB compressed)
- **Linux amd64** — Ubuntu 22.04+ (~253 MB compressed)
- **Linux arm64** — Ubuntu 22.04+ (~251 MB compressed)
- **Windows amd64** — Windows 10/11 (`.zip`, ~188 MB compressed)

Get them from [GitHub Releases](https://github.com/Olib-AI/owl-light/releases/latest)
or via the [installer script](#quick-start). The Linux tarballs are plain
Ubuntu binaries — extract and run, no container required. If you do want
to run it inside a container, [docs/docker.md](docs/docker.md) shows how
to build a thin image around the tarball yourself. The Windows zip ships
a portable `owl_light.exe` plus the CEF runtime DLLs alongside it; no
installer or admin rights required.

---

## Quick start

### One-liner installer (macOS / Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh
```

The script auto-detects your OS + arch, downloads the latest release tarball,
extracts to `~/.owl-light/`, and adds `owl-light` to `PATH`.

### One-liner installer (Windows)

```powershell
iwr -useb https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.ps1 | iex
```

PowerShell only — extracts to `%LOCALAPPDATA%\OwlLight\` and drops an
`owl-light.cmd` shim under `%LOCALAPPDATA%\OwlLight\bin\`. No admin rights
needed; the script prints how to add the bin dir to `PATH` for new shells.

### Manual

1. Grab the right archive from [Releases](https://github.com/Olib-AI/owl-light/releases/latest).
2. Extract it.
3. Run the binary:

   - **macOS**: `owl_light-macos-arm64/owl_light.app/Contents/MacOS/owl_light --remote-debugging-port=9222`
   - **Linux**: `owl_light-linux-{amd64,arm64}/owl_light --remote-debugging-port=9222`
   - **Windows**: from the extracted `owl_light-windows-amd64\` folder, run
     `.\owl_light.exe --remote-debugging-port=9222`. PowerShell or `cmd`
     both work; the exe must stay alongside `libcef.dll` and the rest of
     the runtime files.

---

## Examples

Working code in [`examples/`](examples/):

- **[Playwright + Python](examples/playwright-python/)** — connect, fill a form, take a full-page screenshot, handle popups.
- **[Playwright + Node.js](examples/playwright-node/)** — same flows in TypeScript-friendly JS.
- **[Puppeteer](examples/puppeteer/)** — connect over CDP, use the standard Puppeteer API.

```python
# examples/playwright-python/screenshot.py
import asyncio
from playwright.async_api import async_playwright

async def main():
    async with async_playwright() as p:
        browser = await p.chromium.connect_over_cdp("http://localhost:9222")
        page = browser.contexts[0].pages[0]
        await page.set_viewport_size({"width": 1440, "height": 900})
        await page.goto("https://www.olib.ai", wait_until="networkidle")
        await page.screenshot(path="olib.png", full_page=True)

asyncio.run(main())
```

---

## Profile selection

Owl Light ships with **15 production-grade fingerprint profiles** —
3 operating systems × 5 Chrome versions:

| `--owl-os=` | `--owl-chrome-version=` |
|---|---|
| `windows`, `macos`, `linux` | `143`, `144`, `145`, `146`, `147` |

```bash
owl-light --remote-debugging-port=9222 --owl-os=linux --owl-chrome-version=145
```

Each profile is a fully self-consistent identity — UA, Sec-CH-UA-* hints,
GPU/WebGL renderer, canvas/audio noise seed, font list, screen metrics, and
timezone are all coherent for that OS/version combination.

See [docs/profiles.md](docs/profiles.md) for the full matrix.

---

## Verifying it works

The classic stealth gauntlet:

```bash
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147 &

# fingerprint.com
playwright codegen http://localhost:9222 https://fingerprint.com/products/bot-detection/
# → "Not detected"

# bot.sannysoft
…visit https://bot.sannysoft.com → all green checkmarks
```

The full e2e validation suite (18 tests, Playwright + Puppeteer × CDP) lives
in the source repo and is run on every release.

---

## Browser flags

Owl Light is a Chromium fork — **all standard Chromium flags work**. The
Owl-specific knobs are:

| Flag | What it does |
|---|---|
| `--owl-os={windows\|macos\|linux}` | Pick the spoofed operating system |
| `--owl-chrome-version={143..147}` | Pick the spoofed Chrome major version |
| `--owl-vm-seed=<n>` | Force a specific VM profile (advanced) |
| `--remote-debugging-port=<n>` | Standard CDP port (default: pipe-only) |

Defaults to `linux` + `chrome 147` if not specified. See
[docs/flags.md](docs/flags.md) for the complete list.

---

## License

Owl Light binaries are distributed under the **MIT License** — see
[LICENSE](LICENSE). The source code is proprietary to Olib AI and is not
included in this repository.

You may redistribute the binary as part of your application or service. We
ask (but do not require) that you link back to https://www.owlbrowser.net so
others can find it.

---

## Enterprise

<div align="center">
  <img src="web/assets/owl-watching.svg" alt="" width="180" height="180"/>
</div>

Owl Light is the open distribution. **[Owl Browser Enterprise](https://www.owlbrowser.net)**
is the full platform built around the same engine, for teams running
automation at scale:

| | Owl Light | **Owl Browser Enterprise** |
|---|---|---|
| Stealth Chromium engine | ✓ | ✓ |
| Platforms | macOS, Linux, Windows | macOS, Linux, Windows, Docker |
| Fingerprint profiles | 15 bundled | 256 unique per instance, custom matrices |
| Multi-context isolation | — | 256 isolated browser contexts per process |
| Tor integration | — | Built-in, per-context circuits |
| Built-in proxy / residential routing | — | ✓ |
| 175+ automation tools (REST + WebSocket + MCP) | — | ✓ |
| Vision LLM (page understanding, NLA, CAPTCHA) | — | ✓ — on-device, Qwen3-VL-2B |
| Video recording, live streaming, frame capture | — | ✓ |
| 64-socket parallel IPC | — | ✓ |
| React control panel + REST API | — | ✓ |
| Audit logging, SOC2 hardening, RS256 license | — | ✓ |
| Support | Community | Dedicated SLA, private Slack |

[**Talk to us →**](https://www.owlbrowser.net) · [sales@olib.ai](mailto:sales@olib.ai)

---

## Links

- 🌐 [owlbrowser.net](https://www.owlbrowser.net) — product site
- 📚 [docs/](docs/) — install, flags, profiles, FAQ
- 💡 [examples/](examples/) — runnable Playwright + Puppeteer samples
- 🐛 [Issues](https://github.com/Olib-AI/owl-light/issues) — bugs & feature requests
- ✉️ [hello@olib.ai](mailto:hello@olib.ai)

<div align="center" style="opacity: 0.6; margin-top: 2rem;">
  <sub>Built by <a href="https://www.olib.ai">Olib AI</a> · Made with 🦉 in San Francisco</sub>
</div>
