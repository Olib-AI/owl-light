# Running Owl Light inside a container

Owl Light **does not currently publish a Docker image** — releases ship as
plain `tar.gz` archives. The Linux tarballs are regular Ubuntu 22.04+
binaries; you can drop them into any Linux container yourself.

This page shows the minimal Dockerfile that wraps the official tarball.

## Minimal Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM ubuntu:22.04 AS runtime

ARG OWL_LIGHT_VERSION=v0.1.0
ARG TARGETARCH      # amd64 | arm64 (set automatically by buildx)

# CEF runtime deps + tini for clean PID 1
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl tini \
      libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 \
      libdrm2 libgbm1 libxkbcommon0 libxcomposite1 libxdamage1 \
      libxfixes3 libxrandr2 libxshmfence1 libasound2 libpango-1.0-0 \
      libcairo2 libdbus-1-3 fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Pull the published tarball matching the build platform
RUN curl -fsSL \
      "https://github.com/Olib-AI/owl-light/releases/download/${OWL_LIGHT_VERSION}/owl_light-linux-${TARGETARCH}.tar.gz" \
      -o /tmp/owl.tgz \
    && tar -xzf /tmp/owl.tgz -C /opt \
    && mv "/opt/linux-${TARGETARCH}" /opt/owl-light \
    && rm /tmp/owl.tgz \
    && useradd -u 1000 -ms /bin/bash owl

USER owl
EXPOSE 9222
ENTRYPOINT ["/usr/bin/tini", "--", "/opt/owl-light/owl_light", \
            "--no-sandbox", "--remote-debugging-port=9222", \
            "--remote-debugging-address=0.0.0.0"]
```

Build it:

```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg OWL_LIGHT_VERSION=v0.1.0 \
  -t my-org/owl-light:v0.1.0 \
  --push .
```

Run it:

```bash
docker run --rm -p 9222:9222 my-org/owl-light:v0.1.0 \
  --owl-os=macos --owl-chrome-version=147
```

Anything you append on the `docker run` line gets passed to the binary as
extra flags (it's merged with the ENTRYPOINT default args).

## Talking to it from your host

```python
from playwright.async_api import async_playwright

async with async_playwright() as p:
    browser = await p.chromium.connect_over_cdp("http://localhost:9222")
    page = browser.contexts[0].pages[0]
    await page.goto("https://example.com")
```

## Persistent user data

Cookies, localStorage, IndexedDB live under whatever `--user-data-dir` you
pass. Default is a tmpfs inside the container — gone when the container
exits. To keep them, mount a volume:

```bash
docker run --rm -p 9222:9222 \
  -v owl-light-data:/data \
  my-org/owl-light:v0.1.0 \
  --user-data-dir=/data \
  --owl-os=macos --owl-chrome-version=147
```

## Resource sizing

| Workload | Suggested |
|---|---|
| 1 page, light scraping | 0.5 CPU, 512 MB RAM |
| 4–6 concurrent pages | 2 CPU, 2 GB RAM |
| Heavy SPA / WebGL / video | 4+ CPU, 4 GB RAM |

CEF spawns helper processes (renderer, GPU, network) — leave headroom
above your page count.

## Sandbox

The Dockerfile above passes `--no-sandbox` because the Chromium setuid
sandbox needs `CAP_SYS_ADMIN`, which most container runtimes drop. If your
runtime allows it, drop `--no-sandbox` from the ENTRYPOINT and run with
`--cap-add=SYS_ADMIN`.

## Why no official image?

Publishing one means committing to a security-update SLA, image-signing
infrastructure, and per-arch CI. We may add it later. In the meantime the
five lines above are the entire delta from the tarball, so most users are
better off rolling their own thin wrapper than waiting on us.

If you need a hardened image (signed, SBOM-attached, vuln-scanned) for
production use, the [Enterprise build](https://www.owlbrowser.net) ships
one as part of the deployment bundle.
