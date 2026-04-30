#!/usr/bin/env sh
# =============================================================================
# Owl Light installer — one-liner: curl -fsSL https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.sh | sh
# =============================================================================
# Detects OS + arch, downloads the latest Owl Light release tarball from
# GitHub, extracts to ~/.owl-light/, and adds the binary to PATH via a shim
# in ~/.local/bin/owl-light. POSIX sh, no bash-isms — should run on every
# default macOS / Ubuntu install.
# =============================================================================
set -eu

REPO="${OWL_LIGHT_REPO:-Olib-AI/owl-light}"
INSTALL_DIR="${OWL_LIGHT_HOME:-$HOME/.owl-light}"
BIN_DIR="${OWL_LIGHT_BIN_DIR:-$HOME/.local/bin}"
VERSION="${OWL_LIGHT_VERSION:-latest}"

# ANSI green / red — falls back to plain text if not a tty
if [ -t 1 ]; then
  G='\033[0;32m'; R='\033[0;31m'; Y='\033[1;33m'; N='\033[0m'
else
  G=''; R=''; Y=''; N=''
fi
say()  { printf "${G}==>${N} %s\n" "$1"; }
warn() { printf "${Y}!! ${N} %s\n" "$1"; }
die()  { printf "${R}xx ${N} %s\n" "$1" >&2; exit 1; }

# ----- platform detection -----------------------------------------------------
uname_s="$(uname -s)"
uname_m="$(uname -m)"

case "$uname_s" in
  Darwin)
    case "$uname_m" in
      arm64|aarch64) PLATFORM="macos-arm64" ;;
      *) die "Owl Light only ships an Apple Silicon build for macOS — your CPU is $uname_m" ;;
    esac ;;
  Linux)
    case "$uname_m" in
      x86_64|amd64) PLATFORM="linux-amd64" ;;
      aarch64|arm64) PLATFORM="linux-arm64" ;;
      *) die "Unsupported Linux CPU: $uname_m" ;;
    esac ;;
  *) die "Unsupported OS: $uname_s. Owl Light supports macOS and Linux." ;;
esac
say "detected $PLATFORM"

# ----- prerequisites ----------------------------------------------------------
need() { command -v "$1" >/dev/null 2>&1 || die "missing required tool: $1"; }
need curl; need tar; need uname

# ----- resolve version --------------------------------------------------------
if [ "$VERSION" = "latest" ]; then
  say "resolving latest release..."
  TAG="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
          | sed -nE 's/.*"tag_name": *"([^"]+)".*/\1/p' | head -1)"
  [ -n "${TAG:-}" ] || die "could not resolve latest tag from GitHub API"
else
  TAG="$VERSION"
fi
say "installing $TAG"

# ----- download + extract -----------------------------------------------------
TARBALL="owl_light-${PLATFORM}.tar.gz"
URL="https://github.com/${REPO}/releases/download/${TAG}/${TARBALL}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

say "downloading ${URL}"
curl -fL --progress-bar -o "${TMP}/${TARBALL}" "$URL" \
  || die "download failed — check https://github.com/${REPO}/releases"

mkdir -p "$INSTALL_DIR"
say "extracting to $INSTALL_DIR"
tar -xzf "${TMP}/${TARBALL}" -C "$INSTALL_DIR"

# ----- create shim ------------------------------------------------------------
mkdir -p "$BIN_DIR"
SHIM="${BIN_DIR}/owl-light"

case "$PLATFORM" in
  macos-arm64)
    BINARY="${INSTALL_DIR}/owl_light.app/Contents/MacOS/owl_light"
    ;;
  linux-*)
    BINARY="${INSTALL_DIR}/${PLATFORM}/owl_light"
    ;;
esac

cat > "$SHIM" <<EOF
#!/usr/bin/env sh
exec "$BINARY" "\$@"
EOF
chmod +x "$SHIM"

say "installed: $SHIM"

# ----- PATH guidance ----------------------------------------------------------
case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *)
    warn "$BIN_DIR is not on your PATH"
    echo "    add this to your shell profile (~/.bashrc, ~/.zshrc, ~/.profile):"
    echo
    echo "        export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ;;
esac

# ----- smoke test -------------------------------------------------------------
if "$BINARY" --version 2>/dev/null | head -1; then
  say "✓ Owl Light $TAG installed successfully"
else
  say "✓ binary copied to $BINARY"
fi

cat <<'POST'

  Try it:

    owl-light --remote-debugging-port=9222 --owl-os=macos --owl-chrome-version=147

  Then connect from Playwright:

    browser = await p.chromium.connect_over_cdp("http://localhost:9222")

  Docs:     https://github.com/Olib-AI/owl-light#examples
  Examples: https://github.com/Olib-AI/owl-light/tree/main/examples
  Site:     https://www.owlbrowser.net

POST
