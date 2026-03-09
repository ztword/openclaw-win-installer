#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "Updating apt and installing prerequisites..."
sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  git

OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/openclaw}"

if [[ ! -d "$OPENCLAW_DIR/.git" ]]; then
  echo "Cloning OpenClaw into: $OPENCLAW_DIR"
  git clone https://github.com/pjasicek/OpenClaw.git "$OPENCLAW_DIR"
else
  echo "OpenClaw repo already exists at $OPENCLAW_DIR; pulling latest changes..."
  git -C "$OPENCLAW_DIR" pull --ff-only
fi

echo ""
echo "Done."
echo "Repo location: $OPENCLAW_DIR"
echo "You can now follow OpenClaw's upstream build instructions."
