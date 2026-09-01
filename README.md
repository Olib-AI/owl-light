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
to drive a real browser from **Playwright** or **Puppeteer**, but you want
the page to look like a regular user, not a headless bot.

It's a custom Chromium build with hardware-level fingerprint virtualization
compiled directly into the engine: GPU, canvas, WebGL, audio, fonts, navigator,
`Sec-CH-UA-*` headers, timezone, locale, and more. The spoofed values come
from the same Blink code paths as real ones, so JavaScript introspection,
`toString()` checks, and prototype-chain audits all see authentic values.

It speaks vanilla CDP. Your existing `connect_over_cdp(...)` /
`puppeteer.connect({ browserURL })` code keeps working. Point it at
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

That's it. No SDK, no client library, just the Chrome DevTools Protocol you
already speak.

---

## Why?

| | Plain Chromium / Playwright | **Owl Light** |
|---|---|---|
| Fingerprint | Identical to every other Playwright user | 150 bundled VM profiles (Windows, macOS, Linux × Chrome 143-152), each with a fully self-consistent identity |
| Detection by Cloudflare / DataDome / fingerprint.com | Frequently flagged as bot | Passes |
| `navigator.webdriver` | `true` | `undefined` (and so is every other tell) |
| GPU / canvas / WebGL | Real machine, leaks identity | Virtualized at the C++ source level |
| Setup | Brittle stealth plugins, monkey-patched at runtime | One binary, zero JS injection |
| Compatible with | Playwright, Puppeteer | **Same.** Drop-in, no API changes |

---

## Platforms

Pre-built binaries for:

- **macOS arm64**: Apple Silicon (`.app` bundle, ~164 MB compressed, Developer ID signed and notarized)
- **Linux amd64**: Ubuntu 22.04+ (~200 MB compressed)
- **Linux arm64**: Ubuntu 22.04+ (~194 MB compressed)
- **Windows amd64**: Windows 10/11 (`.zip`, ~190 MB compressed)

All four platforms are built from the same engine revision, currently
**CEF 152.0.5 / Chromium 152.0.7977.65**.

Get them from [GitHub Releases](https://github.com/Olib-AI/owl-light/releases/latest)
or via the [installer script](#quick-start). The Linux tarballs are plain
Ubuntu binaries: extract and run, no container required. If you do want
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

PowerShell only. Extracts to `%LOCALAPPDATA%\OwlLight\` and drops an
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

- **[Playwright + Python](examples/playwright-python/)**: connect, fill a form, take a full-page screenshot, handle popups.
- **[Playwright + Node.js](examples/playwright-node/)**: same flows in TypeScript-friendly JS.
- **[Puppeteer](examples/puppeteer/)**: connect over CDP, use the standard Puppeteer API.

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

Owl Light ships with **150 production-grade fingerprint profiles**:
3 operating systems x 5 hardware builds x 10 Chrome versions.

| `--owl-os=` | `--owl-chrome-version=` |
|---|---|
| `windows`, `macos`, `linux` | `143`, `144`, `145`, `146`, `147`, `148`, `149`, `150`, `151`, `152` |

```bash
owl-light --remote-debugging-port=9222 --owl-os=linux --owl-chrome-version=145
```

With no flags, Owl Light picks a profile at random across all 150. Pin one
exactly with `--owl-profile-id=<1..150>`.

Each profile is a fully self-consistent identity: UA, Sec-CH-UA-* hints,
GPU/WebGL renderer, canvas/audio noise seed, font list, and screen metrics are
all coherent for that OS, hardware, and version combination. The 5 hardware
builds per OS mean two sessions on the same Chrome version can still present
genuinely different GPUs and screen geometry.

Timezone is deliberately **not** derived from the profile. See
[Timezone](#timezone) below.

See [docs/profiles.md](docs/profiles.md) for the full matrix.

---

## Timezone

By default Owl Light reports **your host timezone**, exactly as stock Chrome
does. It does not invent a timezone to match the profile, because Owl Light
does no GeoIP lookup and a guessed zone would be wrong more often than right.

If you send traffic through a proxy or VPN, set the zone to the exit country
yourself:

```bash
owl-light --remote-debugging-port=9222 --owl-timezone=Europe/Berlin
```

A browser timezone that disagrees with the exit IP is one of the most widely
deployed anti-fraud signals there is, so set this whenever the traffic leaves
from somewhere other than your own machine. The value is any IANA zone id, for
example `America/New_York`, `Europe/Berlin`, or `Asia/Tokyo`.

`--owl-timezone` drives the whole stack, not just `Intl`: `Date`, the
`Intl.DateTimeFormat` resolved options, and the ICU default zone all agree, so
there is no offset mismatch to detect.

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

Owl Light is a Chromium fork, so **all standard Chromium flags work**. The
Owl-specific knobs are:

| Flag | What it does |
|---|---|
| `--owl-os={windows\|macos\|linux}` | Filter profile selection by OS. Default: random across all 3 |
| `--owl-chrome-version={143..152}` | Pin the reported Chrome major. Default: random across all 10 |
| `--owl-timezone=<IANA zone>` | Timezone reported to the page. Default: your host timezone |
| `--owl-profile-id={1..150}` | Pin one exact profile row, overriding the two flags above |
| `--owl-seed=<uint64>` | Deterministic seed for canvas / audio / WebGL noise. Same seed, same fingerprint |
| `--owl-help` | Print the Owl flag reference and exit |
| `--remote-debugging-port=<n>` | Standard CDP port (default: pipe-only) |

With no Owl flags at all, Owl Light picks a random profile and reports your
host timezone. Run `owl-light --owl-help` for the authoritative list, or see
[docs/flags.md](docs/flags.md).

---

## License

Owl Light binaries are distributed under the **MIT License**. See
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

Owl Light is the open distribution, free to use and supported on a best effort
basis. It is a separate product from Enterprise and is not covered by the Owl
Browser bug bounty programme. See [SECURITY.md](SECURITY.md) for what that
means for security reports.

**[Owl Browser Enterprise](https://www.owlbrowser.net)** is the full platform
built around the same engine, for teams running automation at scale:

| | Owl Light | **Owl Browser Enterprise** |
|---|---|---|
| Stealth Chromium engine | ✓ | ✓ |
| Platforms | macOS, Linux, Windows | macOS, Linux, Windows, Docker |
| Fingerprint profiles | 150 bundled | 256 unique per instance, custom matrices |
| Multi-context isolation | ✗ | 256 isolated browser contexts per process |
| Tor integration | ✗ | Built-in, per-context circuits |
| Built-in proxy / residential routing | ✗ | ✓ |
| 175+ automation tools (REST + WebSocket + MCP) | ✗ | ✓ |
| Vision LLM (page understanding, NLA, CAPTCHA) | ✗ | ✓ on-device, Qwen3-VL-2B |
| Video recording, live streaming, frame capture | ✗ | ✓ |
| 64-socket parallel IPC | ✗ | ✓ |
| React control panel + REST API | ✗ | ✓ |
| Audit logging, SOC2 hardening, RS256 license | ✗ | ✓ |
| Support | Community | Dedicated SLA, private Slack |

[**Talk to us →**](https://www.owlbrowser.net) · [sales@olib.ai](mailto:sales@olib.ai)

---

## Links

- 🌐 [owlbrowser.net](https://www.owlbrowser.net): product site
- 📚 [docs/](docs/): install, flags, profiles, FAQ
- 💡 [examples/](examples/): runnable Playwright + Puppeteer samples
- 🐛 [Issues](https://github.com/Olib-AI/owl-light/issues): bugs & feature requests
- ✉️ [hello@olib.ai](mailto:hello@olib.ai)

<div align="center" style="opacity: 0.6; margin-top: 2rem;">
  <sub>Built by <a href="https://www.olib.ai">Olib AI</a> · Made with 🦉 in Stone Mountain</sub>
</div>
