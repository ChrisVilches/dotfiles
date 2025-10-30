# The purpose of putting this file here is to:
# * Modify it and change bindings.
# * Create my own stuff.
# * Get more used to using fzf (with popups or vanilla commands in general).
#
# This file came from fzf itself (examples folder).
# Check the ones with `bindkey`, these are the enabled ones.

if [[ $- == *i* ]]; then

# Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_CTRL_T_OPTS" $(__fzfcmd) -m "$@" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzf_use_tmux__() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
  __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER} $(__fsel)"
  local ret=$?
  zle reset-prompt
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# Ensure precmds are run after cd
fzf-redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N fzf-redraw-prompt

# cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . -mindepth 1 \\( -path '*/\\.*' -o -fstype 'sysfs' -o -fstype 'devfs' -o -fstype 'devtmpfs' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | cut -b3-"}"
  setopt localoptions pipefail no_aliases 2> /dev/null
  local dir="$(eval "$cmd" | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} --reverse $FZF_DEFAULT_OPTS $FZF_ALT_C_OPTS" $(__fzfcmd) +m)"
  if [[ -z "$dir" ]]; then
    zle redisplay
    return 0
  fi
  cd "$dir"
  unset dir # ensure this doesn't end up appearing in prompt expansion
  local ret=$?
  zle fzf-redraw-prompt
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '^G' fzf-cd-widget

# Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null

  # This seems to obtain only the number.

  # NOTE: This had some hallucinations at first, so some of this explanation might be wrong lol.
  # fc -rl 1 → reverse history, newest first. ✅
  # FZF_DEFAULT_OPTS="..." → sets fzf appearance and behavior for this invocation.
  # -n2..,.. → tells fzf to ignore the first column (history numbers) when matching, only match on the command itself. This is huge for convenience.
  # --tiebreak=index → if two matches have equal score, pick the most recent first.
  # --bind=ctrl-r:toggle-sort → lets you switch between normal/fuzzy sorting on the fly.
  # --query=${(qqq)LBUFFER} → automatically pre-fills the query with whatever is already typed on the command line.
  # +m → disables multi select.
  # selected=( $( ... ) ) → captures the selected line(s) into an array for further use.

  # Removed --bind=ctrl-r:toggle-sort (I never used it and doesn't seem very useful).
  selected=( $(fc -rl 1 |
    FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index $FZF_CTRL_R_OPTS --query=${(qqq)LBUFFER} +m" $(__fzfcmd)) )
  local ret=$?

  # The number obtained above is used here.
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      # Fetch the history line specified by the numeric argument. This defaults to the current history line (i.e. the one that isn’t history yet).
      zle vi-fetch-history -n $num
    fi
  fi

  # Redraws the $ if it gets messed up.
  zle reset-prompt

  # This is the exit status
  return $ret
}
# Create new ZLE widget function (and bind it to a keymap)
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

# Custom stuff, just to try it. Not very useful.
fzf-ls() {
  # Run fzf in full-screen, capture the selected item
  local selected
  selected=$(ls -lha | fzf)

  # If user picked something (didn't cancel)
  if [[ -n $selected ]]; then
    # Do something with the result — for example, insert into command line:
    LBUFFER+=$selected
  fi

  # Restore the prompt correctly
  zle reset-prompt
}

zle -N fzf-ls
bindkey '^F' fzf-ls

fi

