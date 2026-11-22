# Fingerprint profiles

Owl Light ships with **240 production-grade profiles**: 3 operating systems
x 5 hardware builds x 16 Chrome major versions. Each profile is a fully
self-consistent identity: navigator object, Client Hints (`Sec-CH-UA-*`),
Accept-Language, platform, GPU/WebGL renderer, canvas noise seed, audio
fingerprint, font list, screen metrics, devicePixelRatio, hardwareConcurrency
and deviceMemory all match what a real machine of that build would produce.

Timezone is deliberately not part of the profile. Owl Light reports the host
timezone unless you set `--owl-timezone`. See [Timezone](#timezone) below.

## Matrix

| `--owl-os=` | UA platform | Hardware builds | Chrome majors |
|---|---|---|---|
| `windows` | Windows 10/11 (`Win32`) | 5: NVIDIA RTX A2000, RTX A4000, RTX 5000 Ada Generation; AMD Radeon RX 6750 XT, RX 7700 XT | 143 to 158 |
| `macos` | macOS 14+ (`MacIntel`) | 5: Apple M2, M2 Pro, M2 Max, M3 Pro, M4 Max | 143 to 158 |
| `linux` | Linux x86_64 | 5: NVIDIA GeForce RTX 2060, RTX 4050 Laptop, RTX 4080 Laptop; AMD Radeon RX 6600 XT, RX 6700 XT | 143 to 158 |

3 operating systems x 5 hardware builds x 16 Chrome majors = **240 profiles**,
addressable individually as `--owl-profile-id=1..240`.

The 5 hardware builds per operating system are what make two sessions on the
same Chrome version genuinely different: they carry distinct GPU and WebGL
renderer strings, screen geometry, devicePixelRatio, hardwareConcurrency and
deviceMemory, not just a different noise seed.

The matrix is bundled into the binary itself (encrypted SQLCipher DB): no
network calls, no profile downloads, no telemetry.

## Hardware builds

What a page reads for each hardware build. The GPU column is the WebGL
`UNMASKED_RENDERER_WEBGL` string; the profile ids are every Chrome major of
that build (143 to 158).

| OS | GPU (`UNMASKED_RENDERER_WEBGL`) | Cores | Memory | Screen | DPR | Profile ids |
|---|---|---:|---:|---|---:|---|
| Windows | `ANGLE (NVIDIA, NVIDIA RTX A2000 (0x2571) Direct3D11 vs_5_0 ps_5_0, D3D11)` | 24 | 4 | 1366x768 | 1 | 1-7, 22-23, 28, 151, 166, 181, 196, 211, 226 |
| Windows | `ANGLE (NVIDIA, NVIDIA RTX 5000 Ada Generation (0x26b2) Direct3D11 vs_5_0 ps_5_0, D3D11)` | 12 | 8 | 1920x1080 | 1 | 31-37, 52-53, 58, 154, 169, 184, 199, 214, 229 |
| Windows | `ANGLE (AMD, AMD Radeon RX 6750 XT (0x73df) Direct3D11 vs_5_0 ps_5_0, D3D11)` | 16 | 8 | 1920x1080 | 1 | 61-67, 82-83, 88, 157, 172, 187, 202, 217, 232 |
| Windows | `ANGLE (NVIDIA, NVIDIA RTX A4000 (0x24b0) Direct3D11 vs_5_0 ps_5_0, D3D11)` | 12 | 8 | 1920x1080 | 1 | 91-97, 112-113, 118, 160, 175, 190, 205, 220, 235 |
| Windows | `ANGLE (AMD, AMD Radeon RX 7700 XT (0x747e) Direct3D11 vs_5_0 ps_5_0, D3D11)` | 12 | 8 | 2560x1440 | 1 | 121-127, 142-143, 148, 163, 178, 193, 208, 223, 238 |
| macOS | `ANGLE (Apple, ANGLE Metal Renderer: Apple M2 Pro, Unspecified Version)` | 12 | 8 | 2560x1440 | 2 | 8-14, 24-25, 29, 152, 167, 182, 197, 212, 227 |
| macOS | `ANGLE (Apple, ANGLE Metal Renderer: Apple M2 Max, Unspecified Version)` | 12 | 8 | 1512x982 | 2 | 38-44, 54-55, 59, 155, 170, 185, 200, 215, 230 |
| macOS | `ANGLE (Apple, ANGLE Metal Renderer: Apple M3 Pro, Unspecified Version)` | 11 | 8 | 1512x982 | 2 | 68-74, 84-85, 89, 158, 173, 188, 203, 218, 233 |
| macOS | `ANGLE (Apple, ANGLE Metal Renderer: Apple M2, Unspecified Version)` | 8 | 8 | 1280x832 | 2 | 98-104, 114-115, 119, 161, 176, 191, 206, 221, 236 |
| macOS | `ANGLE (Apple, ANGLE Metal Renderer: Apple M4 Max, Unspecified Version)` | 14 | 8 | 1512x982 | 2 | 128-134, 144-145, 149, 164, 179, 194, 209, 224, 239 |
| Linux | `ANGLE (AMD, AMD Radeon RX 6700 XT (navi22 LLVM 15.0.6), OpenGL 4.6)` | 24 | 8 | 2560x1440 | 1 | 15-21, 26-27, 30, 153, 168, 183, 198, 213, 228 |
| Linux | `ANGLE (NVIDIA Corporation, NVIDIA GeForce RTX 4080 Laptop GPU/PCIe/SSE2, OpenGL 4.6.0)` | 20 | 8 | 2560x1440 | 1 | 45-51, 56-57, 60, 156, 171, 186, 201, 216, 231 |
| Linux | `ANGLE (AMD, AMD Radeon RX 6600 XT (radeonsi navi23 LLVM 19.1.0), OpenGL 4.6)` | 6 | 8 | 2560x1440 | 1 | 75-81, 86-87, 90, 159, 174, 189, 204, 219, 234 |
| Linux | `ANGLE (NVIDIA Corporation, NVIDIA GeForce RTX 2060/PCIe/SSE2, OpenGL 4.6.0)` | 24 | 8 | 1920x1080 | 1 | 105-111, 116-117, 120, 162, 177, 192, 207, 222, 237 |
| Linux | `ANGLE (NVIDIA Corporation, NVIDIA GeForce RTX 4050 Laptop GPU/PCIe/SSE2, OpenGL 4.6.0)` | 22 | 4 | 1920x1080 | 1 | 135-141, 146-147, 150, 165, 180, 195, 210, 225, 240 |

Cores is `navigator.hardwareConcurrency`, Memory is `navigator.deviceMemory`
(GB), Screen is `screen.width` x `screen.height`.

### Camera, microphone and speakers

`navigator.mediaDevices.enumerateDevices()` lists the devices the profile's
hardware has, not the host's:

| Hardware | Devices listed |
|---|---|
| Laptops: macOS M2, M2 Max, M3 Pro, M4 Max; Linux RTX 4080 Laptop, RTX 4050 Laptop | microphone, camera, speakers |
| macOS M2 Pro (external display) and the three Linux desktops | speakers |
| Windows desktops (all five Windows builds) | none |

As in real Chrome, labels and device ids are empty until the page is granted
access. Owl Light never answers the permission prompt, so `getUserMedia()`
stays pending for a device the profile has (and `navigator.permissions.query`
reports `prompt`), and rejects with `NotFoundError` for a device it lacks. The
host's real camera and microphone are never opened.

If your automation needs `getUserMedia()` to succeed, add Chromium's
`--use-fake-ui-for-media-stream`. It grants every capture request with
synthetic devices, and it also exposes device labels before any request,
which real Chrome does not do.

### WebGPU

`navigator.gpu.requestAdapter()` follows real Chrome 158 on the claimed OS:

- **Linux profiles**: no adapter (`requestAdapter()` resolves `null`), as in
  real Chrome 158 on Linux.
- **Windows and macOS profiles**: the adapter's info, features and limits are
  those of the claimed GPU. A GPU without published data gets no adapter. In
  the bundled roster that leaves an adapter on the Windows RX 6750 XT
  (`amd`/`rdna-2`), Windows RX 7700 XT (`amd`/`rdna-3`) and macOS M4 Max
  (`apple`/`metal-3`) builds; every other build resolves `null`.

A profile can only report an adapter when the host itself has a usable
WebGPU adapter. In a container without a GPU, every profile resolves `null`.

## Pinning a profile

By default Owl Light picks one of the 240 profiles at random per process
launch. To pin the exact same identity across runs, address it by id:

```bash
# always use the same identity
owl-light --owl-profile-id=42
```

`--owl-profile-id` overrides `--owl-os` and `--owl-chrome-version`. Ids are
append-only across releases, so a pinned id keeps selecting the same VM after
an upgrade: ids 1 to 150 select the same VMs as in v0.4.x, ids 151 to 210
the same as in v0.5.x, and ids 211 to 240 are the Chrome 157 and 158
additions (211 to 225 are Chrome 157, 226 to 240 are Chrome 158). An id
outside the bundled roster is rejected at startup with an error naming the
flag.

To narrow the random pick instead of pinning it, combine the filters:

```bash
owl-light --owl-os=macos --owl-chrome-version=147
```

For a reproducible per-context noise pattern (canvas, WebGL hashing), add
`--owl-seed=<uint64>`. The same seed produces the same noise. The audio
fingerprint does not depend on the seed: it is the value real Chrome produces
on the claimed OS (see [What's spoofed](#whats-spoofed)).

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

## Fonts

Owl Light bundles only open-source fonts: Liberation (metric-compatible with
Arial, Times New Roman and Courier New), DejaVu and Noto, plus Carlito
(Calibri metrics), Caladea (Cambria metrics) and Selawik (Segoe UI metrics)
in every package. On a Linux host a Windows profile's Arial is Owl Win Sans,
Liberation Sans with Arial's bounding box (OFL-licensed, renamed as the
license requires), so text inputs size as on real Windows. The proprietary Windows and macOS faces
cannot be redistributed, so a profile whose OS uses them gets these
substitutes. Faces with no open-source equivalent (Consolas, Georgia,
Verdana, Tahoma and others) are approximations: text set in them can measure
and render differently from a real machine of that OS.

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
- AudioContext: the realtime context's sample rate and latency come from the
  profile; the OfflineAudioContext fingerprint is the exact value real Chrome
  produces on the claimed OS (`124.0434748024636` for macOS profiles,
  `124.04347776696522` for Windows and Linux profiles)
- Fonts: platform-coherent installed-font list visible to canvas
  measureText, document.fonts API, and CSS measurement. The generic families
  (`serif`, `sans-serif`, `monospace`, `cursive`, `fantasy`, `system-ui`) and
  the CSS system font keywords (`font: menu`, `status-bar`, `small-caption`)
  resolve as on the claimed OS
- Platform surface: Web Share (`navigator.share`, `navigator.canShare`), Web
  Bluetooth (`navigator.bluetooth`) and `BarcodeDetector` are present or
  absent as in real Chrome on the claimed OS; Windows and Linux profiles get
  classic 15px scrollbars, macOS profiles overlay scrollbars;
  `navigator.keyboard.getLayoutMap()` returns the claimed OS's US layout; the
  focus ring colour and CSS system colours follow the claimed OS
- Screen: `screen.width`, `screen.height`, `screen.availWidth`,
  `screen.availHeight`, `devicePixelRatio`, `screen.colorDepth`,
  `screen.orientation`
- Timezone: `Intl.DateTimeFormat().resolvedOptions().timeZone`,
  `Date.prototype.getTimezoneOffset()` and the computed UTC offset, all driven
  from the ICU default zone. Host zone by default, `--owl-timezone` to set it
- WebRTC: ICE candidate suppression for the host's real IP, and the
  `disable_non_proxied_udp` IP handling policy, so WebRTC never sends UDP
  around a configured proxy (without a proxy, no candidates are gathered)
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

Owl Light's 240 bundled profiles are the public set. Owl Browser
**Enterprise** ships **256 unique profiles per instance** plus a profile
generator that synthesizes new identities from any Chrome major you point
it at. See [Enterprise](enterprise.md).
