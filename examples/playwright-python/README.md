# Playwright + Python · Owl Light examples

Vanilla Playwright code that connects to a running Owl Light over CDP. No
SDK, no monkey-patching — `connect_over_cdp` is all you need.

## Setup

```bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt

# in another terminal: start Owl Light
owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147
```

## Examples

| File | What it shows |
|---|---|
| [`01_basic.py`](01_basic.py) | Connect, navigate, read the page title |
| [`02_screenshot.py`](02_screenshot.py) | Full-page PNG of any URL |
| [`03_form_login.py`](03_form_login.py) | Fill + submit a login form, assert success |
| [`04_multiwindow.py`](04_multiwindow.py) | Open `target=_blank`, drive the new tab |
| [`05_intercept_network.py`](05_intercept_network.py) | Intercept and rewrite requests |
| [`06_stealth_check.py`](06_stealth_check.py) | Visit a fingerprint test page and assert "not detected" |

Each script is self-contained — `python 01_basic.py` and you're off.
