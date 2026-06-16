# Owl Browser Enterprise

Owl Light is the open distribution of the stealth Chromium engine —
suitable for individual scripts, side projects, and small-scale
automation.

When you outgrow it, **[Owl Browser Enterprise](https://www.owlbrowser.net)**
is the full platform built around the same engine, for teams running
automation at scale.

## What's in Enterprise

| | Owl Light | **Owl Browser Enterprise** |
|---|---|---|
| Stealth Chromium engine | ✓ | ✓ (same engine, expanded profile pool) |
| Platforms | macOS arm64, Linux amd64/arm64, Windows amd64 | macOS, Linux, Windows, Docker (multi-arch) |
| Bundled fingerprint profiles | 21 (3 OS × 7 Chrome versions) | 256 unique per instance, custom matrices, profile generator API |
| Multi-context isolation | — | 256 isolated browser contexts per process, each with its own profile |
| Concurrent sessions | One CDP client | 256+ parallel sessions, 64-socket parallel IPC |
| Tor integration | — | Built-in, per-context circuits, NEW-NYM rotation |
| Residential proxy routing | manual `--proxy-server=...` | Per-context proxy pool, geo-targeted, sticky sessions |
| Automation tools | CDP only | 175+ tools via REST + WebSocket + MCP (browser_*, ai_*, captcha_*, video_*, network_*, …) |
| Vision LLM | — | On-device Qwen3-VL-2B (Metal/CUDA/Vulkan) for page understanding, NLA, CAPTCHA |
| CAPTCHA solver | — | Heuristic + vision-based (text, image grid, checkbox, puzzle) |
| Video recording | — | H.264 / WebM, live MJPEG streaming, frame-on-demand capture |
| Network interception | Playwright route() | Dedicated rule engine, mock responses, request log, blocker stats |
| Content extraction | — | Readability, HTML→Markdown, JSON, site-specific templates, crawling |
| Control panel | — | React + Tailwind UI (port 80), live monitoring, replay |
| REST API | — | OpenAPI 3.1 schema, generated SDKs (Node + Python) |
| MCP server | — | 157 tools for AI agents (Claude, GPT, agents on your stack) |
| Audit logging | — | Structured JSON, per-action attribution |
| SOC2 hardening | — | Non-root, capability dropping, BuildKit secrets, AES-256-GCM at rest, RS256 license, HMAC-SHA256 signed traffic |
| Support | Community Issues | Dedicated SLA, private Slack channel, on-call escalation |

## When to upgrade

You should consider Enterprise if you:

- Need **more than ~5 concurrent sessions** from a single host.
- Want **persistent isolated contexts** (one browser context per "user account") rather than spinning up Owl Light processes.
- Are hitting **CAPTCHAs you can't solve manually** and want to automate them.
- Need **Tor circuits** routed per session, with rotation policies.
- Want to drive the browser from an **AI agent** via the MCP protocol.
- Are recording **video** of automation runs for QA / replay.
- Need **SOC2-grade auditability** (financial, healthcare, regulated).
- Need **Windows** support.

## Architecture

Enterprise wraps the same stealth Chromium engine in:

- A **C99 HTTP server** (poll-based, non-blocking, 64-socket IPC pool to the browser process) — handles REST + WebSocket + MJPEG streaming.
- An **MCP server** (TypeScript) — exposes 157 tools to AI agents.
- A **React control panel** (Vite + Tailwind) — live dashboard, profile management, log inspection.
- A **license server** (Flask + PostgreSQL) — RS256 JWTs, fingerprint binding, offline-capable validation.
- An **on-device vision LLM** (llama.cpp + Qwen3-VL-2B, 32K context, 16 parallel slots).

Deploy as a single Docker container with `docker run` and you have all of
it — the React panel auto-publishes on port 80, the API on 8080, MCP over
stdio.

## Talk to us

[**Schedule a demo →**](https://www.owlbrowser.net) ·
[sales@olib.ai](mailto:sales@olib.ai) ·
[hello@olib.ai](mailto:hello@olib.ai)

We typically respond within a business day. If you're evaluating against
Browserbase, Bright Data Browser API, BrowserScan, or Hyperbrowser, ask us
for a side-by-side comparison — we publish the test methodology.
