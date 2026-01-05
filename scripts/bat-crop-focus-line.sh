#!/bin/sh

# Displays a file with bat, highlighting a given line and showing a limited
# range of lines around it, cropping the rest.

extra_lines=10

start=$(($2 - extra_lines))
if [ $start -lt 1 ]; then
  # increase end to compensate
  end=$(($2 + extra_lines + (1 - start)))
  start=1
else
  end=$(($2 + extra_lines))
fi

bat --style=numbers --color=always --highlight-line "$2" --line-range $start:$end "$1"
