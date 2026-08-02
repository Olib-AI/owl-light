# Flags reference

Owl Light is a Chromium fork — every standard Chromium command-line flag
works. The Owl-specific knobs are listed first; everything else is the
upstream Chromium catalogue (`--headless=new`, `--no-sandbox`,
`--proxy-server=...`, `--user-data-dir=...`, `--disable-dev-shm-usage`, …).

## Owl-specific flags

| Flag | Default | What it does |
|---|---|---|
| `--owl-os={windows\|macos\|linux}` | `linux` | Pick the spoofed operating system. Drives navigator.platform, navigator.userAgent, Sec-CH-UA-Platform, font list, screen DPI, and a dozen other coherent invariants. |
| `--owl-chrome-version={143..151}` | `147` | Pick the spoofed Chrome major version. Drives the entire User-Agent stack and Sec-CH-UA-Full-Version-List. |
| `--owl-vm-seed=<u64>` | (random per run) | Force a specific VM profile by seed. Use this when you need *the same* identity across runs (regression testing, account binding). |
| `--owl-gpu-profile=<n>` | (auto from `--owl-os`) | Override the GPU virtualization slot. 0 = Intel UHD, 1 = NVIDIA, 2 = AMD, 3 = Apple M-series, 4 = Qualcomm Adreno. |

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
  --owl-os=windows \
  --owl-chrome-version=146 \
  --owl-vm-seed=4242424242424242
```

Through a residential proxy with a Linux identity:

```bash
owl-light \
  --remote-debugging-port=9222 \
  --owl-os=linux \
  --owl-chrome-version=147 \
  --proxy-server=http://user:pass@proxy.example.com:8080
```

## Listing every Chromium flag

The full Chromium flag catalogue lives at
[`peter.sh/experiments/chromium-command-line-switches`](https://peter.sh/experiments/chromium-command-line-switches).
Most of them apply to Owl Light unchanged.
