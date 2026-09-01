# Flags reference

Owl Light is a Chromium fork, so every standard Chromium command-line flag
works. The Owl-specific knobs are listed first; everything else is the
upstream Chromium catalogue (`--headless=new`, `--no-sandbox`,
`--proxy-server=...`, `--user-data-dir=...`, `--disable-dev-shm-usage`, …).

## Owl-specific flags

| Flag | Default | What it does |
|---|---|---|
| `--owl-os={windows\|macos\|linux}` | random across all 3 | Filter profile selection by operating system. Drives navigator.platform, navigator.userAgent, Sec-CH-UA-Platform, font list, screen DPI, and a dozen other coherent invariants. |
| `--owl-chrome-version={143..152}` | random across all 10 | Pin the spoofed Chrome major version. Drives the entire User-Agent stack and Sec-CH-UA-Full-Version-List. |
| `--owl-profile-id={1..150}` | (none) | Pin one exact profile row, overriding `--owl-os` and `--owl-chrome-version`. Use this when you need *the same* identity across runs (regression testing, account binding). Ids are append-only across releases. |
| `--owl-timezone=<IANA zone>` | the host timezone | Timezone reported to the page, for example `Europe/Berlin`. Sets the ICU default zone, so `Date`, `Intl` and the computed offset all agree. Set this to your proxy's exit country. |
| `--owl-seed=<u64>` | (random per run) | Deterministic seed for per-context noise (canvas, audio, WebGL hashing). The same seed produces the same noise. |
| `--owl-help` | | Print the Owl flag reference and exit. |

Run `owl-light --owl-help` for the authoritative list as built into your
binary.

## Common Chromium flags you'll actually use

| Flag | Effect |
|---|---|
| `--remote-debugging-port=<n>` | Expose CDP over HTTP on `<n>`. Required for `connect_over_cdp`. |
| `--remote-debugging-address=0.0.0.0` | Bind CDP to all interfaces (Docker / containers). |
| `--user-data-dir=<path>` | Where cookies, localStorage, etc. persist. Use a fresh dir per session. |
| `--headless=new` | Modern Chromium headless mode. Owl Light defaults to this when no display is attached. |
| `--no-sandbox` | Drop the seccomp sandbox. Needed inside containers and CI. |
| `--disable-gpu` | Skip GPU rasterization. |
| `--proxy-server=http://user:pass@host:port` | Route all traffic through a proxy. |
| `--lang=en-US,en;q=0.9` | Override the Accept-Language header. |
| `--window-size=1920,1080` | Initial viewport (overridden by Playwright's set_viewport_size). |
| `--disable-dev-shm-usage` | Use `/tmp` instead of `/dev/shm` (smaller container default). |

## Examples

A typical invocation for headless automation:

```bash
owl-light \
  --remote-debugging-port=9222 \
  --remote-debugging-address=0.0.0.0 \
  --user-data-dir=/tmp/owl-session-$$ \
  --headless=new \
  --no-sandbox \
  --disable-gpu \
  --owl-os=macos \
  --owl-chrome-version=147
```

A reproducible session bound to a specific identity:

```bash
owl-light \
  --remote-debugging-port=9222 \
  --owl-profile-id=42 \
  --owl-seed=4242424242424242
```

Through a residential proxy with a Linux identity. Set the timezone to the
proxy's exit country: a browser timezone that disagrees with the exit IP is
one of the most widely deployed anti-fraud signals there is.

```bash
owl-light \
  --remote-debugging-port=9222 \
  --owl-os=linux \
  --owl-chrome-version=147 \
  --owl-timezone=Europe/Berlin \
  --proxy-server=http://user:pass@proxy.example.com:8080
```

## Listing every Chromium flag

The full Chromium flag catalogue lives at
[`peter.sh/experiments/chromium-command-line-switches`](https://peter.sh/experiments/chromium-command-line-switches).
Most of them apply to Owl Light unchanged.
