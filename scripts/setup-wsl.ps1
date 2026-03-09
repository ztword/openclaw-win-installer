Param(
  [string]$Distro = "Ubuntu"
)

$ErrorActionPreference = "Stop"

Write-Host "Enabling WSL and Virtual Machine Platform (may require reboot)..."

try {
  dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
  dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
} catch {
  Write-Host "Failed to enable Windows features. Please run PowerShell as Administrator."
  throw
}

Write-Host "Setting WSL default version to 2..."
wsl --set-default-version 2 | Out-Null

Write-Host "Installing distro: $Distro (if not already installed)..."
try {
  wsl --install -d $Distro
} catch {
  Write-Host "WSL install command failed. If WSL is already installed, you can ignore this and open your distro manually."
}

Write-Host ""
Write-Host "Next steps:"
Write-Host "1) Launch your distro from Start Menu or run: wsl -d $Distro"
Write-Host "2) In WSL, run: bash ./scripts/install-openclaw.sh"
