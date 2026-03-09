# openclaw-win-installer

Helper project to set up and run OpenClaw on Windows via WSL.

## Quick Start

1. Open PowerShell as Administrator
2. Run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\setup-wsl.ps1
```

3. Inside WSL, run:

```bash
bash ./scripts/install-openclaw.sh
```

## Structure

- scripts: setup and installation scripts
- assets: images and demo media used by docs
- docs: FAQ and security docs
