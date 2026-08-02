# Installing Owl Light

Pre-built binaries are published on
[GitHub Releases](https://github.com/Olib-AI/owl-light/releases/latest)
for four targets:

| Archive | Platform |
|---|---|
| `owl_light-macos-arm64.tar.gz` | macOS 12+ on Apple Silicon (M1/M2/M3/M4) |
| `owl_light-linux-amd64.tar.gz` | Ubuntu 22.04+ / Debian 12+ on x86_64 |
| `owl_light-linux-arm64.tar.gz` | Ubuntu 22.04+ / Debian 12+ on aarch64 |
| `owl_light-windows-amd64.zip`  | Windows 10/11 on x86_64 |

The macOS Intel and Windows arm64 builds are not currently shipped —
please open an issue if you need either.

---

## Method 1 — installer script (recommended)

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh
```

What it does:

1. Detects your OS + CPU.
2. Resolves the latest release tag from the GitHub API.
3. Downloads the matching tarball, verifies it extracts cleanly.
4. Stages the tree under `~/.owl-light/`.
5. Drops a tiny shim at `~/.local/bin/owl-light` that execs the right binary.
6. Tells you if `~/.local/bin` isn't on your `PATH` yet.

Pin to a version:

```bash
OWL_LIGHT_VERSION=v0.3.0 curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh
```

Customize the install location:

```bash
OWL_LIGHT_HOME=/opt/owl-light \
OWL_LIGHT_BIN_DIR=/usr/local/bin \
  curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sudo sh
```

### Windows

```powershell
iwr -useb https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.ps1 | iex
```

Same idea, PowerShell. Extracts to `%LOCALAPPDATA%\OwlLight\` and drops
`%LOCALAPPDATA%\OwlLight\bin\owl-light.cmd` as the shim. No admin rights
needed; the script prints how to add the bin dir to your user `PATH`.

Pin a version or change the install dir:

```powershell
$env:OWL_LIGHT_VERSION = 'v0.3.0'
$env:OWL_LIGHT_HOME    = 'C:\Tools\OwlLight'
iwr -useb https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.ps1 | iex
```

---

## Method 2 — manual

### Linux

```bash
curl -L -O https://github.com/Olib-AI/owl-light/releases/latest/download/owl_light-linux-amd64.tar.gz

mkdir -p ~/owl-light && tar -xzf owl_light-linux-amd64.tar.gz -C ~/owl-light

# run
~/owl-light/linux-amd64/owl_light --remote-debugging-port=9222
```

### macOS

```bash
tar -xzf owl_light-macos-arm64.tar.gz
open owl_light.app             # GUI launcher
# or run the binary directly:
./owl_light.app/Contents/MacOS/owl_light --remote-debugging-port=9222
```

### Windows

```powershell
# PowerShell
Invoke-WebRequest -OutFile owl_light-windows-amd64.zip `
  https://github.com/Olib-AI/owl-light/releases/latest/download/owl_light-windows-amd64.zip
Expand-Archive owl_light-windows-amd64.zip -DestinationPath C:\Tools\OwlLight
cd C:\Tools\OwlLight
.\owl_light.exe --remote-debugging-port=9222
```

`owl_light.exe` is portable — keep it in the same folder as `libcef.dll`
and the rest of the runtime files. No installer, no admin rights, no
service registration.

---

## Method 3 — Inside a container

We don't currently publish a Docker image. The Linux tarballs are plain
Ubuntu 22.04+ binaries; if you need to run it in a container, drop the
tarball into your own ~30-line Dockerfile. See [docker.md](docker.md)
for a copy-paste example.

---

## Verify

```bash
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147 &
curl -s http://localhost:9222/json/version | head
```

You should see Chromium-style JSON with the spoofed user agent. From your
test code, point Playwright/Puppeteer at `http://localhost:9222` and you're
done — see [examples/](../examples/).

---

## Uninstall

```bash
rm -rf ~/.owl-light ~/.local/bin/owl-light
```

If you used a custom `OWL_LIGHT_HOME` / `OWL_LIGHT_BIN_DIR`, point the
removal at those paths instead.
