# =============================================================================
# Owl Light installer for Windows
# =============================================================================
# One-liner:
#   iwr -useb https://raw.githubusercontent.com/Olib-AI/owl-light/main/scripts/install.ps1 | iex
#
# Downloads the latest Owl Light Windows release zip from GitHub, extracts
# it to %LOCALAPPDATA%\OwlLight\, and adds a `owl-light.cmd` shim on PATH
# (under %LOCALAPPDATA%\OwlLight\bin\). No admin rights needed.
# =============================================================================
$ErrorActionPreference = 'Stop'

function Say($msg)  { Write-Host "==> $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "!!  $msg" -ForegroundColor Yellow }
function Die($msg)  { Write-Host "xx  $msg" -ForegroundColor Red; exit 1 }

$Repo       = $env:OWL_LIGHT_REPO    ; if (-not $Repo)       { $Repo       = 'Olib-AI/owl-light' }
$Version    = $env:OWL_LIGHT_VERSION ; if (-not $Version)    { $Version    = 'latest' }
$InstallDir = $env:OWL_LIGHT_HOME    ; if (-not $InstallDir) { $InstallDir = Join-Path $env:LOCALAPPDATA 'OwlLight' }
$BinDir     = Join-Path $InstallDir 'bin'

if (-not [Environment]::Is64BitOperatingSystem) {
    Die 'Owl Light requires 64-bit Windows. Detected 32-bit OS.'
}

# ---- resolve tag ----
if ($Version -eq 'latest') {
    Say 'resolving latest release...'
    $latest = Invoke-RestMethod -UseBasicParsing `
        -Uri "https://api.github.com/repos/$Repo/releases/latest"
    $Tag = $latest.tag_name
    if (-not $Tag) { Die 'could not resolve latest tag from GitHub API' }
} else {
    $Tag = $Version
}
Say "installing $Tag"

# ---- download ----
$Zip = 'owl_light-windows-amd64.zip'
$Url = "https://github.com/$Repo/releases/download/$Tag/$Zip"
$Tmp = Join-Path ([System.IO.Path]::GetTempPath()) "owl-light-install-$([Guid]::NewGuid())"
New-Item -ItemType Directory -Force -Path $Tmp | Out-Null
$ZipPath = Join-Path $Tmp $Zip
try {
    Say "downloading $Url"
    & curl.exe -fL --progress-bar -o $ZipPath $Url
    if ($LASTEXITCODE -ne 0) { Die "download failed -- check https://github.com/$Repo/releases" }

    # ---- extract ----
    if (Test-Path $InstallDir) {
        Warn "$InstallDir already exists -- replacing contents"
        # Don't blow away user data dirs; just overwrite the runtime files.
    }
    New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null
    Say "extracting to $InstallDir"
    Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force

    # ---- shim ----
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    $Exe  = Join-Path $InstallDir 'owl_light.exe'
    if (-not (Test-Path $Exe)) {
        Die "extraction succeeded but owl_light.exe missing at $Exe"
    }
    $Shim = Join-Path $BinDir 'owl-light.cmd'
    @"
@echo off
"$Exe" %*
"@ | Out-File -FilePath $Shim -Encoding ASCII -Force
    Say "installed: $Shim"

    # ---- PATH guidance ----
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if ($userPath -notlike "*$BinDir*") {
        Warn "$BinDir is not on your user PATH"
        Write-Host "    add it for future shells with:"
        Write-Host ""
        Write-Host "        [Environment]::SetEnvironmentVariable('Path', `"`$env:Path;$BinDir`", 'User')"
        Write-Host ""
        Write-Host '    or run:'
        Write-Host ""
        Write-Host "        setx PATH `"%PATH%;$BinDir`""
        Write-Host ''
    }

    # ---- smoke ----
    $version = & $Exe --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Say "OK Owl Light $Tag installed: $version"
    } else {
        Say "OK binary copied to $Exe"
    }

    Write-Host ''
    Write-Host '  Try it:'
    Write-Host ''
    Write-Host "    $Shim --remote-debugging-port=9222 --owl-os=windows --owl-chrome-version=147"
    Write-Host ''
    Write-Host '  Then connect from Playwright:'
    Write-Host ''
    Write-Host '    browser = await p.chromium.connect_over_cdp("http://localhost:9222")'
    Write-Host ''
    Write-Host '  Docs:     https://github.com/Olib-AI/owl-light#examples'
    Write-Host '  Examples: https://github.com/Olib-AI/owl-light/tree/main/examples'
    Write-Host '  Site:     https://www.owlbrowser.net'
    Write-Host ''
} finally {
    Remove-Item -Recurse -Force $Tmp -EA SilentlyContinue
}
