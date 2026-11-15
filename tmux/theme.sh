#!/bin/bash

# Apply a tmux theme: `theme.sh NAME` builds tmux config from theme-NAME.sh and
# loads it. A theme file only holds data (its colours, as bash variables), and
# build() below turns it into tmux options, so every theme shares one layout.
# The config is saved in the gitignored current-theme.conf, which tmux.conf
# sources at startup, so editing a theme file takes effect once the theme is
# applied again. Without a NAME it removes current-theme.conf, which leaves
# tmux's own default look.
#
# `theme.sh --init` applies current-theme.conf as it is (or the default look
# without one) and binds prefix T to a menu of the themes, which calls this
# script. tmux.conf runs it at startup.

dir=$(dirname "$(readlink -f "$0")")

# Every option build() can set. Themes only `set -g` options, which overwrite
# tmux's global defaults, and nothing undoes that when another theme is loaded:
# an option set by the old theme but not by the new one would keep the old
# theme's value. So all of these are unset with `set -gu`, which brings back
# tmux's built-in value, before the new theme sets its own.
options=(
  status-style status-left status-right-length status-right
  window-status-separator window-status-format window-status-current-format
  window-status-current-style window-status-activity-style
  window-status-bell-style pane-border-lines pane-border-style
  pane-border-format message-style message-command-style mode-style
  clock-mode-colour @window_color
)

# Nerd Font glyphs, written as UTF-8 bytes: the rounded left and right ends of
# a pill, and an expand arrow that themes can use as their zoom marker.
pill_left=$'\356\202\266'
pill_right=$'\356\202\264'
zoom_arrow=$'\363\260\201\214'

# Print the tmux config for theme NAME. Colours are anything tmux takes as a
# colour, including a format such as '#{E:@window_color}'.
#
#   shape              block (padded blocks) or pill (rounded, needs a Nerd Font)
#   bold               yes or no, for the program block, current window and
#                      active pane label
#   bar_bg bar_fg      the status bar
#   program_fg program_bg program_prefix_bg
#                      the program block on the right, whose background changes
#                      while the prefix key is pressed
#   window_fg          the other windows' text
#   current_fg current_bg
#                      the current window's block
#   current_marker current_marker_fg
#                      optional text in front of the current window (block shape
#                      only), in place of its left padding
#   window_colors      optional array of colours: each window gets one from its
#                      window ID (@1, @2, ...), which never changes, so a window
#                      keeps its colour when windows are moved or renumbered.
#                      Themes use it as '#{E:@window_color}'.
#   zoom               marker shown after a zoomed window's name
#   border_lines border_fg
#                      pane borders (border_lines is single, double, heavy, ...)
#   label_fg label_active_fg label_active_bg
#                      pane labels on the borders; label_active_bg is optional
#   message_bg message_fg command_bg command_fg mode_bg
#                      messages, the command prompt and copy mode selection
#   activity_style bell_style clock_color
#                      optional
build() {
  shape=block bold=yes zoom='[Z]' border_lines=single
  current_marker= current_marker_fg= label_active_bg= window_colors=()
  activity_style= bell_style= clock_color=
  source "$dir/theme-$1.sh"

  # A colour the theme forgot would be an empty string, which tmux ignores in
  # formats without a word, so the theme would just look slightly off.
  local name
  for name in bar_bg bar_fg program_fg program_bg program_prefix_bg window_fg \
      current_fg current_bg border_fg label_fg label_active_fg message_bg \
      message_fg command_bg command_fg mode_bg; do
    [ -n "${!name}" ] || { echo "theme-$1.sh doesn't set $name" >&2; return 1; }
  done

  local b= path='#{s|^$HOME|~|:pane_current_path}'
  [ "$bold" = yes ] && b=,bold
  # A window's tab shows the name it was given with prefix , or rename-window
  # (which turns automatic-rename off for that window), or else its path.
  local title="#{?automatic-rename,$path,#{window_name}}"
  local zoomed="#{?window_zoomed_flag, $zoom,}"
  local program="#{?client_prefix,$program_prefix_bg,$program_bg}"

  local separator right current
  if [ "$shape" = pill ]; then
    separator=' '
    right="#[fg=$program,bg=default]$pill_left#[fg=$program_fg,bg=$program$b]#{pane_current_command}#[nobold,fg=$program,bg=default]$pill_right"
    current="#[fg=$current_bg,bg=default]$pill_left#[fg=$current_fg,bg=$current_bg$b]$title$zoomed#[nobold,fg=$current_bg,bg=default]$pill_right"
  else
    separator=''
    right="#[fg=$program_fg,bg=$program$b] #{pane_current_command} "
    if [ -n "$current_marker" ]; then
      current="#[fg=$current_marker_fg,bg=$current_bg]$current_marker#[fg=$current_fg$b]$title$zoomed "
    else
      current="#[fg=$current_fg,bg=$current_bg$b] $title$zoomed "
    fi
  fi

  # Window colour lookup: window ID modulo the number of colours, as nested
  # conditions with the last colour as the fallback.
  local n=${#window_colors[@]}
  if [ "$n" -gt 0 ]; then
    local lookup=${window_colors[n - 1]} i
    for ((i = n - 2; i >= 0; i--)); do
      lookup="#{?#{==:#{e|%:#{s/@//:window_id},$n},$i},${window_colors[i]},$lookup}"
    done
    echo "set -g @window_color \"$lookup\""
  fi

  # Commas inside a #{?...} condition are escaped as #, in the pane label.
  cat <<EOF
set -g status-style "bg=$bar_bg,fg=$bar_fg"
set -g status-left ""
set -g status-right-length 80
set -g status-right "$right"

set -g window-status-separator "$separator"
set -g window-status-format " #[fg=$window_fg]$title$zoomed "
set -g window-status-current-format "$current"
set -g window-status-current-style "default"

set -g pane-border-lines $border_lines
set -g pane-border-style "fg=$border_fg"
set -g pane-border-format "#[align=centre]#{?pane_active,#[fg=$label_active_fg${label_active_bg:+#,bg=$label_active_bg}${b:+#,bold}],#[fg=$label_fg]} #P: $path "

set -g message-style "bg=$message_bg,fg=$message_fg"
set -g message-command-style "bg=$command_bg,fg=$command_fg"
set -g mode-style "bg=$mode_bg,bold"
EOF
  [ -n "$activity_style" ] && echo "set -g window-status-activity-style \"$activity_style\""
  [ -n "$bell_style" ] && echo "set -g window-status-bell-style \"$bell_style\""
  [ -n "$clock_color" ] && echo "set -g clock-mode-colour $clock_color"
  return 0
}

# The menu has one item per theme file, under the key the file sets as
# menu_key, and a last item for tmux's default look.
bind_menu() {
  local items=() file name key
  for file in "$dir"/theme-*.sh; do
    name=${file##*/theme-} name=${name%.sh}
    key=$(source "$file"; echo "$menu_key")
    items+=("$name" "$key" "run '$dir/theme.sh $name'")
  done
  tmux bind T display-menu -T Theme "${items[@]}" tmux t "run '$dir/theme.sh'"
}

# The unsetting and current-theme.conf go to tmux as one piece of config on
# stdin (`source-file -` reads from stdin, though the man page doesn't say so).
# source-file reads all of it before running any command, so the commands run
# back to back and tmux has no chance to redraw in between and show its default
# look for a moment, as it can when they come from separate tmux calls.
apply() {
  {
    printf 'set -gu %s\n' "${options[@]}"
    cat "$dir/current-theme.conf" 2>/dev/null
  } | tmux source-file -
}

if [ "$1" = --init ]; then
  bind_menu
  apply
  exit
fi

if [ -n "$1" ] && [ ! -f "$dir/theme-$1.sh" ]; then
  echo "No theme named $1: $dir/theme-$1.sh doesn't exist" >&2
  exit 1
fi

# Built before current-theme.conf is touched, so a theme that fails the check
# in build() leaves the current one in place.
if [ -n "$1" ]; then
  config=$(build "$1") || exit 1
  echo "$config" > "$dir/current-theme.conf"
else
  rm -f "$dir/current-theme.conf"
fi

apply
