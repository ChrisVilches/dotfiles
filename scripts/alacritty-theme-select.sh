#!/bin/bash

# Pick an Alacritty theme with fzf. Moving through the list previews the theme
# live on every open Alacritty window, ENTER makes the choice permanent, and
# ESC goes back to the theme that was selected before.
#
# "Permanent" means repointing the alacritty/theme.toml symlink of this
# repository, which alacritty.toml imports.
#
# Moving that symlink is the whole mechanism, the preview included: Alacritty
# reloads its configuration when the files it watches change, and that reload
# re-reads everything from scratch, which is what keeps each theme from being
# contaminated by the previous one.
#
# `alacritty msg config` is the other way to repaint a running window, and it is
# the wrong one here: its overrides stack instead of replacing each other, and
# each one only touches the keys it actually names. A theme that leaves the
# cursor colors undefined would keep showing the previous theme's cursor colors.
#
# This needs live_config_reload, which is on by default.

set -u

SCRIPT_PATH=$(readlink -f -- "$0")
REPO_DIR=$(dirname -- "$(dirname -- "$SCRIPT_PATH")")
THEME_LINK="$REPO_DIR/alacritty/theme.toml"
CONFIG_FILE="$REPO_DIR/alacritty/alacritty.toml"

# Points theme.toml at a theme file and makes the running windows notice.
#
# Moving the symlink is not enough on its own. Alacritty checks every filesystem
# event against the exact paths it loaded the configuration from, and it knows
# this symlink as ~/.config/alacritty/theme.toml, while the event arrives
# spelled with this repository's path, because ~/.config/alacritty is a symlink
# to it. The two spellings do not match, so the event is dropped. The main
# configuration file is tracked by its resolved path, which does match, so
# touching it is what triggers the reload -- and that reload follows the symlink
# and picks up the theme.
apply_theme() {
  ln -sfn -- "$1" "$THEME_LINK"
  touch -- "$CONFIG_FILE"
}

# fzf previews a theme by running this script again, so that the line above
# stays the only place that knows how to apply one. This has to come before the
# EXIT trap below, which a preview must not inherit.
case "${1-}" in
--apply)
  apply_theme "$2"
  exit 0
  ;;
esac

# Where the "themes" folder of https://github.com/alacritty/alacritty-theme may
# have been cloned to. The first one that exists wins.
THEMES_DIR_CANDIDATES=(
  "$HOME/.config/alacritty-theme/themes"
  "$HOME/.config/alacritty/themes"
  "$HOME/.local/share/alacritty-theme/themes"
  "/usr/share/alacritty-theme/themes"
)

THEMES_DIR=""

for candidate in "${THEMES_DIR_CANDIDATES[@]}"; do
  if [ -d "$candidate" ]; then
    THEMES_DIR="$candidate"
    break
  fi
done

if [ -z "$THEMES_DIR" ]; then
  echo "Could not find the themes folder of the alacritty-theme repository." >&2
  echo >&2
  echo "Searched in:" >&2
  echo >&2
  printf '    %s\n' "${THEMES_DIR_CANDIDATES[@]}" >&2
  echo >&2
  echo "Clone the repository into one of those locations, for example:" >&2
  echo >&2
  echo "    git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty-theme" >&2
  exit 1
fi

# Previewing moves the symlink, so wherever it pointed when the script started
# is what leaving without choosing goes back to. Empty means no theme had been
# selected yet.
ORIGINAL_THEME=""

if [ -e "$THEME_LINK" ]; then
  ORIGINAL_THEME=$(readlink -f -- "$THEME_LINK")
fi

restore_original_theme() {
  if [ -n "$ORIGINAL_THEME" ]; then
    apply_theme "$ORIGINAL_THEME"
  else
    # There was no theme to go back to, so the symlink should not exist at all.
    # alacritty.toml imports it either way, and a missing import is ignored.
    rm -f -- "$THEME_LINK"
    touch -- "$CONFIG_FILE"
  fi
}

# This covers ESC, Ctrl-C and anything else that ends the script before a theme
# has been chosen. It is dropped once a choice is made.
trap restore_original_theme EXIT

# fzf already quotes whatever replaces {}, so only the directory part is quoted
# here.
preview_command="cat \"$THEMES_DIR\"/{}"
apply_command="\"$SCRIPT_PATH\" --apply \"$THEMES_DIR\"/{}"

THEMES=$(find "$THEMES_DIR" -maxdepth 1 -type f -printf '%P\n')

FZF_OPTIONS=(
  --preview "$preview_command"
  # fzf fires a focus event on the first line as soon as the list shows up,
  # before `load` has had the chance to jump to the theme that is already
  # selected. Previewing that line would repaint every window just for opening
  # the picker, so previewing only starts once the jump is done.
  --bind "start:unbind(focus)"
  --bind "focus:execute-silent($apply_command)"
  # Typing narrows the list without moving the cursor, so the cursor can end up
  # past the last match, and then there is nothing to accept: ENTER would close
  # the picker having selected nothing. Going back to the first match on every
  # keystroke keeps the cursor on something real.
  --bind "change:first"
)

# Open the list on the theme that is currently selected. `pos` counts from 1 in
# the order the lines were fed to fzf. If the selected theme is not in this
# folder (or nothing is selected yet), the list just opens where fzf would open
# it anyway.
#
# This has to happen on the `load` event rather than on `start`, because `start`
# runs before fzf has finished reading the list, and jumping to a position that
# has not been read yet lands on whatever the last line read so far happens to
# be. `load` runs once the whole list is in.
LOAD_ACTIONS="rebind(focus)"

if [ -n "$ORIGINAL_THEME" ]; then
  CURRENT_THEME=$(basename -- "$ORIGINAL_THEME")
  CURRENT_POSITION=$(printf '%s\n' "$THEMES" | grep -n -x -F -- "$CURRENT_THEME" | cut -d: -f1)

  if [ -n "$CURRENT_POSITION" ]; then
    LOAD_ACTIONS="pos($CURRENT_POSITION)+$LOAD_ACTIONS"
  fi
fi

FZF_OPTIONS+=(--bind "load:$LOAD_ACTIONS")

if SELECTED=$(printf '%s\n' "$THEMES" | fzf "${FZF_OPTIONS[@]}"); then

  # Previewing has already pointed the symlink here, except when the accepted
  # theme was never focused, so this is what covers that case.
  apply_theme "$THEMES_DIR/$SELECTED"
  trap - EXIT

  echo "Theme selected: ${SELECTED}"
  echo
  echo "  A symlink was created (this is how a theme gets selected):"
  echo
  echo "    $THEME_LINK"
  echo "      ->  $THEMES_DIR/$SELECTED"
  echo
  echo "  alacritty.toml imports theme.toml, so whatever that symlink points at"
  echo "  is the current theme. Run this script again to point it somewhere else."
fi
# Nothing is printed when no theme is chosen: the EXIT trap puts the previous
# one back, and seeing the colors go back is feedback enough.
