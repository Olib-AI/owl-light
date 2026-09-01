# Fingerprint profiles

Owl Light ships with **150 production-grade profiles**: 3 operating systems
x 5 hardware builds x 10 Chrome major versions. Each profile is a fully
self-consistent identity: navigator object, Client Hints (`Sec-CH-UA-*`),
Accept-Language, platform, GPU/WebGL renderer, canvas/audio noise seed, font
list, screen metrics, devicePixelRatio, hardwareConcurrency and deviceMemory
all match what a real machine of that build would produce.

Timezone is deliberately not part of the profile. Owl Light reports the host
timezone unless you set `--owl-timezone`. See [Timezone](#timezone) below.

## Matrix

| `--owl-os=` | UA platform | Hardware builds | Chrome majors |
|---|---|---|---|
| `windows` | Windows 10/11 (`Win32`) | 5 per OS, drawn from Intel Iris Xe / Arc, NVIDIA GeForce RTX, AMD Radeon RX | 143 to 152 |
| `macos` | macOS 14+ (`MacIntel`) | 5 per OS, Apple M-series | 143 to 152 |
| `linux` | Linux x86_64 | 5 per OS, drawn from Intel Iris Xe / Arc, NVIDIA GeForce RTX, AMD Radeon RX | 143 to 152 |

3 operating systems x 5 hardware builds x 10 Chrome majors = **150 profiles**,
addressable individually as `--owl-profile-id=1..150`.

The 5 hardware builds per operating system are what make two sessions on the
same Chrome version genuinely different: they carry distinct GPU and WebGL
renderer strings, screen geometry, devicePixelRatio, hardwareConcurrency and
deviceMemory, not just a different noise seed.

The matrix is bundled into the binary itself (encrypted SQLCipher DB): no
network calls, no profile downloads, no telemetry.

## Pinning a profile

By default Owl Light picks one of the 150 profiles at random per process
launch. To pin the exact same identity across runs, address it by id:

```bash
# always use the same identity
owl-light --owl-profile-id=42
```

`--owl-profile-id` overrides `--owl-os` and `--owl-chrome-version`. Ids are
append-only across releases, so a pinned id keeps selecting the same VM after
an upgrade: ids 1 to 27 are byte-identical to the v0.3.0 roster.

To narrow the random pick instead of pinning it, combine the filters:

```bash
owl-light --owl-os=macos --owl-chrome-version=147
```

For a reproducible per-context noise pattern (canvas, audio, WebGL hashing),
add `--owl-seed=<uint64>`. The same seed produces the same noise.

## Timezone

Owl Light reports **your host timezone** by default, exactly as stock Chrome
does. It does not derive a zone from the profile, because there is no GeoIP
lookup and a guessed zone would be wrong more often than right.

Set it explicitly when your traffic exits somewhere else:

```bash
owl-light --owl-timezone=Europe/Berlin
```

A browser timezone that disagrees with the exit IP is one of the most widely
deployed anti-fraud signals there is, so set this whenever you use a proxy or
VPN. The value is any IANA zone id.

This sets the ICU default zone rather than patching JavaScript, so `Date`,
`Intl.DateTimeFormat().resolvedOptions()` and the computed offset all agree,
including across DST boundaries.

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
  `Date.prototype.getTimezoneOffset()` and the computed UTC offset, all driven
  from the ICU default zone. Host zone by default, `--owl-timezone` to set it
- WebRTC: ICE candidate suppression for the host's real IP
- And more. See [www.owlbrowser.net/docs](https://www.owlbrowser.net) for
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
*are* the values, so there is no patching layer to detect. They behave
identically to a real browser's properties under introspection,
serialization, and enumeration.

## Need more profiles?

Owl Light's 150 bundled profiles are the public set. Owl Browser
**Enterprise** ships **256 unique profiles per instance** plus a profile
generator that synthesizes new identities from any Chrome major you point
it at. See [Enterprise](enterprise.md).
