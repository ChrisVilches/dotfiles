#!/bin/bash

# Apply a tmux theme: `theme.sh NAME` loads theme-NAME.conf from this folder and
# remembers it by pointing the gitignored current-theme.conf symlink at it.
# Without a NAME it removes that symlink, which leaves tmux's own default look.
# themes.conf sources current-theme.conf at startup, and its prefix T menu
# calls this script.
#
# Themes only `set -g` options, which overwrite tmux's global defaults, and
# nothing undoes that when another theme is loaded: an option set by the old
# theme but not by the new one would keep the old theme's value. So every
# option set by any theme is unset with `set -gu`, which brings back tmux's
# built-in value, and then the new theme is sourced to set its own.

dir=$(dirname "$(readlink -f "$0")")

if [ -n "$1" ]; then
  ln -sfn "theme-$1.conf" "$dir/current-theme.conf"
else
  rm -f "$dir/current-theme.conf"
fi

# The unsetting and the new theme go to tmux as one piece of config on stdin
# (`source-file -` reads from stdin, though the man page doesn't say so).
# source-file reads all of it before running any command, so the commands run
# back to back and tmux has no chance to redraw in between and show its default
# look for a moment, as it can when they come from separate tmux calls.
#
# The options to unset are read from the `set -g OPTION ...` lines of the theme
# files, so a new theme needs no change here. With no theme picked,
# current-theme.conf is missing and only the unsetting is sent.
{
  sed -nE 's/^set -g ([^ ]+).*/set -gu \1/p' "$dir"/theme-*.conf | sort -u
  cat "$dir/current-theme.conf" 2>/dev/null
} | tmux source-file -
