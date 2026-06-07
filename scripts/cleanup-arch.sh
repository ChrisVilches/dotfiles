#!/usr/bin/env bash

set -euo pipefail

echo "=== Arch Linux Cleanup ==="

before=$(df --output=avail / | tail -1)

echo
echo "[1/4] Removing orphaned packages..."

orphans=$(pacman -Qtdq 2>/dev/null || true)

if [[ -n "$orphans" ]]; then
  sudo pacman -Rns --noconfirm $orphans
else
  echo "No orphaned packages found."
fi

echo
echo "[2/4] Cleaning pacman package cache..."

sudo paccache -r

echo
echo "[3/4] Removing cached packages that are no longer installed..."

sudo paccache -ruk0

echo
echo "[4/4] Cleaning yay cache..."

if command -v yay >/dev/null 2>&1; then
  yay -Sc --noconfirm || true
else
  echo "yay not installed."
fi

after=$(df --output=avail / | tail -1)
freed=$((after - before))

echo
echo "=== Done ==="
echo "Approximate space freed: $((freed / 1024)) MB"
