# Docker

Owl Light publishes a multi-arch container image to GitHub Container
Registry:

```
ghcr.io/olib-ai/owl-light:latest      # latest stable
ghcr.io/olib-ai/owl-light:v0.1.0      # pinned version
```

Architectures: `linux/amd64`, `linux/arm64` (one image, manifest list).

## Run

```bash
docker run --rm -p 9222:9222 \
  ghcr.io/olib-ai/owl-light:latest \
  --owl-os=macos --owl-chrome-version=147
```

The default ENTRYPOINT runs `owl_light` headlessly with CDP listening on
`0.0.0.0:9222`. Anything you append on the `docker run` line gets passed to
the binary as additional flags.

From your host:

```python
from playwright.async_api import async_playwright
async with async_playwright() as p:
    browser = await p.chromium.connect_over_cdp("http://localhost:9222")
```

## Persistent user-data

Cookies, localStorage, IndexedDB, etc. live in `/var/lib/owl-light` inside
the container. Mount a volume to keep them across restarts:

```bash
docker run --rm -p 9222:9222 \
  -v owl-light-data:/var/lib/owl-light \
  ghcr.io/olib-ai/owl-light:latest
```

## docker-compose

```yaml
# docker-compose.yml
services:
  owl-light:
    image: ghcr.io/olib-ai/owl-light:latest
    ports:
      - "9222:9222"
    command:
      - --owl-os=macos
      - --owl-chrome-version=147
    volumes:
      - owl-light-data:/var/lib/owl-light
    restart: unless-stopped

volumes:
  owl-light-data:
```

## Resource sizing

| Profile | Suggested |
|---|---|
| 1 page, casual scraping | 0.5 CPU, 512 MB RAM |
| 4-6 concurrent pages | 2 CPU, 2 GB RAM |
| Heavy SPA / video / WebGL | 4+ CPU, 4 GB RAM |

CEF spawns a few helper processes (renderer, GPU, network); leave headroom
above the page count.

## Sandbox / capabilities

The image runs `owl_light` as `uid 1000` (non-root) under `tini`. No
elevated capabilities are required. If you're embedding inside Kubernetes
or a strict runtime that drops `CAP_SYS_ADMIN`, you may need to add
`--cap-add SYS_ADMIN` for Chromium's sandbox; alternatively pass
`--no-sandbox` (already the default in the Dockerfile).

## Building from source

The source repo (private) ships `light/docker/Dockerfile` — a multi-stage
build that consumes pre-extracted CEF distros from `third_party/`. Public
users should consume the `ghcr.io` image; if you need a custom build,
contact [hello@olib.ai](mailto:hello@olib.ai).
