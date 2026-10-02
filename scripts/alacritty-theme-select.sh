#!/bin/bash

# Pick an Alacritty theme with fzf. Moving through the list previews the theme
# live on every open Alacritty window, ENTER makes the choice permanent, and
# ESC goes back to the theme that was selected before.
#
# "Permanent" means repointing the alacritty/theme.toml symlink of this
# repository, which alacritty.toml imports.

set -u

SCRIPT_PATH=$(readlink -f -- "$0")
REPO_DIR=$(dirname -- "$(dirname -- "$SCRIPT_PATH")")
THEME_LINK="$REPO_DIR/alacritty/theme.toml"

# Where the "themes" folder of https://github.com/alacritty/alacritty-theme may
# have been cloned to. The first one that exists wins.
THEMES_DIR_CANDIDATES=(
  "$HOME/.config/alacritty-theme/themes"
  "$HOME/.config/alacritty/themes"
  "$HOME/.local/share/alacritty-theme/themes"
  "/usr/share/alacritty-theme/themes"
)

# Every running Alacritty process has its own IPC socket, and `alacritty msg`
# only talks to one of them (the one named by $ALACRITTY_SOCKET, which is
# inherited from whichever window started this shell and can even be stale).
# Sending the message to every socket is what makes the live preview reach all
# the windows on screen instead of just one. Within a single process, `-w -1`
# covers all of its windows.
apply_to_all_windows() {
  local socket

  for socket in "${XDG_RUNTIME_DIR:-/tmp}"/Alacritty-*.sock; do
    # A socket file can outlive the process that created it, in which case the
    # message fails. That is expected, so the error is discarded.
    alacritty msg -s "$socket" config -w -1 "$@" >/dev/null 2>&1
  done
}

# Goes back to the selected theme, which is whatever theme.toml points at.
#
# `alacritty msg config --reset` cannot be used for this: it drops the runtime
# configuration and leaves the configuration file as it was last loaded, which
# is the theme each window started with rather than the one selected since then.
restore_selected_theme() {
  if [ -e "$THEME_LINK" ]; then
    apply_to_all_windows "$(cat -- "$THEME_LINK")"
  else
    # No theme has ever been selected, so dropping the runtime configuration is
    # the closest thing to going back.
    apply_to_all_windows --reset
  fi
}

# fzf runs this script again to preview a theme, so that the loop above lives in
# a single place. The arguments are a marker file and the theme file.
case "${1-}" in
--apply)
  # fzf fires its focus event once as soon as the list shows up, before any
  # movement. Applying that theme would repaint every window just for opening
  # the picker, so the first event only leaves the marker behind and the colors
  # start changing once something else is focused.
  if [ ! -e "$2" ]; then
    : >"$2"
    exit 0
  fi

  apply_to_all_windows "$(cat -- "$3")"
  exit 0
  ;;
esac

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

MARKER_DIR=$(mktemp -d)
trap 'rm -rf -- "$MARKER_DIR"' EXIT
MARKER="$MARKER_DIR/first-focus-seen"

# fzf already quotes whatever replaces {}, so only the directory part is quoted
# here.
preview_command="cat \"$THEMES_DIR\"/{}"
apply_command="\"$SCRIPT_PATH\" --apply \"$MARKER\" \"$THEMES_DIR\"/{}"

THEMES=$(find "$THEMES_DIR" -maxdepth 1 -type f -printf '%P\n')

FZF_OPTIONS=(
  --preview "$preview_command"
  --bind "focus:execute-silent($apply_command)"
)

# Open the list on the theme that is currently selected, which is whatever
# theme.toml points at. `pos` counts from 1 in the order the lines were fed to
# fzf. If the selected theme is not in this folder (or nothing is selected yet),
# the list just opens where fzf would open it anyway.
#
# This has to happen on the `load` event rather than on `start`, because `start`
# runs before fzf has finished reading the list, and jumping to a position that
# has not been read yet lands on whatever the last line read so far happens to
# be. `load` runs once the whole list is in.
if [ -e "$THEME_LINK" ]; then
  CURRENT_THEME=$(basename -- "$(readlink -f -- "$THEME_LINK")")
  CURRENT_POSITION=$(printf '%s\n' "$THEMES" | grep -n -x -F -- "$CURRENT_THEME" | cut -d: -f1)

  if [ -n "$CURRENT_POSITION" ]; then
    FZF_OPTIONS+=(--bind "load:pos($CURRENT_POSITION)")
  fi
fi

if SELECTED=$(printf '%s\n' "$THEMES" | fzf "${FZF_OPTIONS[@]}"); then

  ln -sfn -- "$THEMES_DIR/$SELECTED" "$THEME_LINK"

  # Alacritty does not notice that a symlink now points somewhere else, so the
  # open windows are told about the theme explicitly. This also covers accepting
  # the theme that was focused first, which was never previewed.
  restore_selected_theme

  echo "Theme selected: ${SELECTED}"
  echo
  echo "  A symlink was created (this is how a theme gets selected):"
  echo
  echo "    $THEME_LINK"
  echo "      ->  $THEMES_DIR/$SELECTED"
  echo
  echo "  alacritty.toml imports theme.toml, so whatever that symlink points at"
  echo "  is the current theme. Run this script again to point it somewhere else."
else
  # Nothing is printed here: seeing the colors go back is feedback enough.
  restore_selected_theme
fi
