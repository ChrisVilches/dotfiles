#!/bin/bash

# Apply a tmux theme: `theme.sh NAME` loads theme-NAME.conf from this folder and
# remembers it by pointing the gitignored current-theme.conf symlink at it.
# Without a NAME it removes that symlink, which leaves tmux's own default look.
#
# Themes only `set -g` options, which overwrite tmux's global defaults, and
# nothing undoes that when another theme is loaded. So first every option set
# by any theme-*.conf file is unset with `set -gu`, which brings back tmux's
# built-in value, and only then is the theme sourced. The option list is read
# from the theme files themselves, so a new theme needs no change here.

dir=$(dirname "$(readlink -f "$0")")

if [ -n "$1" ]; then
  ln -sfn "theme-$1.conf" "$dir/current-theme.conf"
else
  rm -f "$dir/current-theme.conf"
fi

for option in $(sed -nE 's/^set -g ([^ ]+).*/\1/p' "$dir"/theme-*.conf | sort -u); do
  tmux set -gu "$option"
done

tmux source-file -q "$dir/current-theme.conf"
