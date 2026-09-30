#!/bin/sh

# Browse a JSONL file with fzf. The list shows the raw lines (so fzf searches
# the whole JSON text), and the preview window shows the highlighted line
# formatted with jq.

if [ -z "$1" ]; then
  echo "Usage: jsonl-fzf.sh <file.jsonl>" >&2
  exit 1
fi

# jq prints its own message when a line isn't valid JSON, and the preview window
# shows it as is.
fzf --layout=reverse \
  --no-sort \
  --no-input \
  --phony \
  --bind 'j:down,k:up' \
  --bind 'ctrl-j:down+down+down+down+down+down' \
  --bind 'ctrl-k:up+up+up+up+up+up' \
  --bind 'ctrl-r:change-preview-window(down|right)' \
  --bind 'ctrl-d:preview-half-page-down' \
  --bind 'ctrl-u:preview-half-page-up' \
  --preview 'printf "%s\n" {} | jq -C . | fold -s' \
  --preview-window=right:55%:wrap-word <"$1"

echo "Tip: CTRL-R to rotate preview window (down/right)"
echo

echo "Tip: Very long lines scroll in a lousy way. Use jq to print long lines in
the terminal instead."

# TODO: preview scrolling is glitchy when the JSON has too many line breaks. It
# doesn't show all lines, it skips to the end quickly. One way to see it is by
# pressing ENTER and outputting it on screen.
