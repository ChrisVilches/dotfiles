#!/bin/sh

# Search text with ripgrep and filter results interactively using fzf

if [ -z "$1" ]; then
  exit 0
fi

rg_out=$(rg \
  --glob '!package-lock.json' \
  --glob '!tmp' \
  --glob '!log' \
  --line-number --no-heading --color=always "$1"
)

if [ -z "$rg_out" ]; then
  exit 0
fi

echo "$rg_out" | fzf --ansi --delimiter : \
  --preview "bat-crop-focus-line.sh {1} {2}" \
  --preview-window=up:60%:wrap \
  --bind 'enter:become(echo {1}:{2})'

