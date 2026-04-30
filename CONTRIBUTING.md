# Contributing to Owl Light

Owl Light is the open distribution wrapper around the Olib AI custom Chromium
build. The browser source itself is closed; this repository contains the
README, examples, docs, install script, and release plumbing.

## What you can contribute

- **Examples** — new Playwright/Puppeteer recipes under `examples/`
- **Docs** — fixes, clarifications, new pages under `docs/`
- **Installer** — improvements to `scripts/install.sh`
- **Bug reports** — anything you can reproduce, even if you don't have a fix
- **Feedback** — a 0-star review is more useful than no review

## What we can't accept here

- Patches to the browser core itself — those go to the closed source repo.
  If a stealth signal is broken, file an issue with a reproducer and we'll
  fix it upstream.

## Running the examples locally

```bash
git clone https://github.com/Olib-AI/owl-light.git
cd owl-light
./scripts/install.sh                 # downloads the binary into ./bin/
cd examples/playwright-python
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python3 01_basic.py
```

## Reporting a stealth regression

Owl Light is supposed to score zero `lies` on
[creepjs](https://abrahamjuliot.github.io/creepjs/) across all three OS
profiles. If you find a lie, the issue template asks for:

1. The OS profile flag you used (`--owl-os=...`)
2. The Chrome version flag (`--owl-chrome-version=...`)
3. The exact lie key from the creepjs `workerScope` console output
4. A short HTML/JS reproducer if the lie isn't from creepjs

## Pull requests

- One topic per PR.
- For docs/example PRs, run any code blocks you add and confirm they execute.
- Sign off your commits if you can (`git commit -s`); not required.
- Don't add a license header to anything new — the repo-level `LICENSE` covers
  the whole tree.

## Code of conduct

Be decent. We don't have a long document; if your behaviour would embarrass
your employer, it'll embarrass us too.

## Contact

- GitHub issues: <https://github.com/Olib-AI/owl-light/issues>
- Enterprise: <sales@olib.ai>
