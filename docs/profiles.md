# Fingerprint profiles

Owl Light ships with **15 production-grade profiles** — 3 operating systems
× 5 Chrome major versions. Each profile is a fully self-consistent
identity: navigator object, Client Hints (`Sec-CH-UA-*`), Accept-Language,
platform, GPU/WebGL renderer, canvas/audio noise seed, font list, screen
metrics, devicePixelRatio, hardwareConcurrency, deviceMemory, and timezone
all match what a real machine of that build would produce.

## Matrix

| `--owl-os=` | `--owl-chrome-version=` | UA platform | Default GPU |
|---|---|---|---|
| `windows` | 143 | Windows 10/11 | Intel UHD / NVIDIA |
| `windows` | 144 | Windows 10/11 | Intel UHD / NVIDIA |
| `windows` | 145 | Windows 10/11 | Intel UHD / NVIDIA |
| `windows` | 146 | Windows 10/11 | Intel UHD / NVIDIA |
| `windows` | 147 | Windows 10/11 | Intel UHD / NVIDIA |
| `macos`   | 143 | macOS 14+ | Apple M-series |
| `macos`   | 144 | macOS 14+ | Apple M-series |
| `macos`   | 145 | macOS 14+ | Apple M-series |
| `macos`   | 146 | macOS 14+ | Apple M-series |
| `macos`   | 147 | macOS 14+ | Apple M-series |
| `linux`   | 143 | Linux x86_64 | Intel UHD / NVIDIA |
| `linux`   | 144 | Linux x86_64 | Intel UHD / NVIDIA |
| `linux`   | 145 | Linux x86_64 | Intel UHD / NVIDIA |
| `linux`   | 146 | Linux x86_64 | Intel UHD / NVIDIA |
| `linux`   | 147 | Linux x86_64 | Intel UHD / NVIDIA |

The matrix is bundled into the binary itself (encrypted SQLCipher DB) — no
network calls, no profile downloads, no telemetry.

## Pinning a profile

By default Owl Light picks one of the 15 profiles at random per process
launch. To pin to the same profile across runs:

```bash
# always use the same identity
owl-light --owl-os=macos --owl-chrome-version=147 --owl-vm-seed=4242424242424242
```

The seed maps deterministically to a single profile. Two runs with the same
`--owl-os`, `--owl-chrome-version`, and `--owl-vm-seed` produce identical
fingerprints.

## What's spoofed

A non-exhaustive list of properties Owl Light virtualizes at the C++ source
level:

- `navigator.userAgent`, `navigator.platform`, `navigator.appVersion`,
  `navigator.languages`, `navigator.hardwareConcurrency`,
  `navigator.deviceMemory`, `navigator.maxTouchPoints`, `navigator.vendor`,
  `navigator.webdriver` (always `undefined`)
- `Sec-CH-UA`, `Sec-CH-UA-Full-Version-List`, `Sec-CH-UA-Mobile`,
  `Sec-CH-UA-Platform`, `Sec-CH-UA-Platform-Version`, `Sec-CH-UA-Arch`,
  `Sec-CH-UA-Bitness`, `Sec-CH-UA-Model`, `Sec-CH-UA-WoW64`
- WebGL: `UNMASKED_VENDOR_WEBGL`, `UNMASKED_RENDERER_WEBGL`, debug
  extensions, parameter ranges
- Canvas: deterministic noise injection on `toDataURL`, `toBlob`,
  `getImageData`, `OffscreenCanvas` rendering paths
- AudioContext: sample rate, channel data noise, `getChannelData`
  bias, OfflineAudioContext rendering
- Fonts: platform-coherent installed-font list visible to canvas
  measureText, document.fonts API, and CSS measurement
- Screen: `screen.width`, `screen.height`, `screen.availWidth`,
  `screen.availHeight`, `devicePixelRatio`, `screen.colorDepth`,
  `screen.orientation`
- Timezone: `Intl.DateTimeFormat().resolvedOptions().timeZone`,
  `Date.prototype.getTimezoneOffset()` — coherent with the spoofed locale
- WebRTC: ICE candidate suppression for the host's real IP
- And more — see [www.owlbrowser.net/docs](https://www.owlbrowser.net) for
  the full surface.

## Why "at the C++ source level"?

Most stealth libraries (puppeteer-extra-plugin-stealth, playwright-stealth,
etc.) inject JavaScript into every page that overrides browser APIs at
runtime. That works for shallow checks but leaks badly:

- `navigator.userAgent.toString.toString()` reveals "patched" properties.
- Prototype chain inspection finds the override layer.
- Function source comparison (`Object.getOwnPropertyDescriptor(...)`)
  fingerprints the patcher itself.
- Properties accessed before the patch loads are unspoofed.
- Non-renderable contexts (Service Workers, Web Workers, iframes, isolated
  worlds) miss the patches entirely.

Owl Light spoofs at the Blink/V8 source level, so the spoofed values
*are* the values — there's no patching layer to detect. They behave
identically to a real browser's properties under introspection,
serialization, and enumeration.

## Need more profiles?

Owl Light's 15 bundled profiles are the public set. Owl Browser
**Enterprise** ships **256 unique profiles per instance** plus a profile
generator that synthesizes new identities from any Chrome major you point
it at — see [Enterprise](enterprise.md).
