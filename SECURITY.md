# Security policy

## What this repository covers

Owl Light is a free, publicly available browser binary. It is a separate product
from Owl Browser Enterprise and it does not share the Enterprise codebase,
stealth engine, or hardening work.

**Owl Light is not covered by the Owl Browser bug bounty programme, and reports
about it are not eligible for a bounty, a severity rating, or a coordinated
disclosure timeline.** The bounty applies to the Enterprise product only.

Please do not send Owl Light findings to the enterprise security channel. They
will be closed without assessment.

## Reporting an issue in Owl Light

Security issues in Owl Light are handled on a best effort basis through the
public issue tracker of this repository. Open a regular GitHub issue with:

- A short description of the behaviour
- A reproducer (HTML page, script, or network capture)
- Your platform (`uname -a` and `owl_light --version`)

If an issue turns out to allow remote code execution or a sandbox escape in the
installed binary, email **security@olib.ai** instead of filing publicly, and say
clearly in the subject line that it concerns Owl Light. Those two categories are
the only ones we treat as embargoed for this binary.

## Not accepted for Owl Light

The following are expected characteristics of a free binary, not defects, and
reports about them will be closed:

- Fingerprinting or detection of Owl Light by any means, including Web Audio,
  canvas, WebGL, font enumeration, TLS or HTTP signatures, CDP artefacts, and
  scores from third party detection sites. Owl Light makes no anti detection
  guarantee. Undetectability is an Enterprise feature and it is not present
  here.
- Differences between Owl Light and genuine Chromium in any observable API
  surface, including values that appear constant across profiles.
- Anything inherited from upstream Chromium that we have not modified. Report
  those to the Chromium project at <https://issues.chromium.org>.
- Detection through behavioural analysis such as mouse trajectories, timing,
  or interaction patterns. That is a property of the automation using the
  browser, not of the browser.
- Missing hardening, telemetry, or policy controls that the Enterprise build
  provides.

## Owl Browser Enterprise

Enterprise security reports are handled under a separate disclosure agreement
with enterprise customers. If you are an enterprise customer, use the contact in
your agreement. Findings about the Enterprise binary that are submitted through
this repository cannot be assessed, because the affected code is not published
here.

## Credit

We do not run a paid bounty for Owl Light. For confirmed issues that we fix, we
are glad to credit the reporter by name in the release notes, with permission.
