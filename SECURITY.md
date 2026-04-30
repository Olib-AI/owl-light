# Security policy

## Reporting a vulnerability

Email **security@olib.ai** with:

- A short description of the issue
- A reproducer (HTML page, script, network capture, etc.)
- Your platform (`uname -a` + `owl_light --version`)
- Whether the issue affects Owl Light, the Enterprise build, or both

We acknowledge reports within 2 business days and aim to ship a fix within 14
days for confirmed high-severity issues.

Do **not** file a public GitHub issue for security reports.

## Scope

In scope:

- Stealth bypasses — anything that lets a remote site reliably fingerprint the
  binary as Owl Light or as a non-genuine Chromium
- Memory safety bugs in the patched Blink/V8 surface
- Sandbox escapes in the installed binary

Out of scope:

- Issues in upstream Chromium that we haven't modified — please report those
  to <https://chromiumbugs.com>
- Detection of Owl Light by *behavioural* analysis (mouse trajectories, timing
  patterns) — that's an automation-author concern, not a binary issue
- The closed-source Enterprise build's binary fingerprint — handled under a
  separate disclosure agreement with enterprise customers

## Bounty

We do not currently run a paid bounty programme but will publicly credit
researchers (with permission) in the release notes for the version that
contains the fix.
