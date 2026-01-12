# The purpose of putting this file here is to:
# * Modify it and change bindings.
# * Create my own stuff.
# * Get more used to using fzf (with popups or vanilla commands in general).
#
# This file came from fzf itself (examples folder).
# Check the ones with `bindkey`, these are the enabled ones.

__fzf_use_tmux__() {
    [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ]
}

__fzfcmd() {
    __fzf_use_tmux__ &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

find-file-smart() {
    local key file out

    out="$(find . -type f | fzf --expect=enter,ctrl-t,ctrl-v,ctrl-b,ctrl-l,ctrl-n)" || return

    key=${out%%$'\n'*}
    file=${out#*$'\n'}

    case $key in
        enter|'') LBUFFER+=" $file" ;;
        ctrl-t)   zle -I; cat "$file" ;;
        ctrl-v)   LBUFFER+="vim $file" ;;
        ctrl-b)   LBUFFER+="bat $file" ;;
        ctrl-l)   LBUFFER+="less $file" ;;
        ctrl-n)   LBUFFER+="nvim $file" ;;
    esac
}
zle -N find-file-smart
bindkey '^T' find-file-smart

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

# NOTE: It seems using $CURSOR doesn't work, because gsub doesn't work with the $.
CURSOR_MARKER='_CURSOR_'

# TODO: A command with a "\n" will render a newline in the description. It should be kept as is.
# sed 's/,/\n/g'
format_cheatsheet_entries() {
    awk -v cursor="$CURSOR_MARKER" '{
    output = $0
    display = $0
    desc = ""

    if (match($0, /^(.*)#([^#]*)$/, parts)) {
      output = parts[1]
      desc = parts[2]
    }

    cmd_clean = output
    gsub(cursor, "", cmd_clean)
    gsub(cursor, "", display)

    printf "%s\t%s\t%s\t%s\n", display, output, cmd_clean, desc
  }'
}

cheatsheet_picker() {
    local CHEATSHEET
    local sheet_filename="cheatsheet.sh"
    for sheet_path in "$HOME/dev/dotfiles/$sheet_filename" "$HOME/dotfiles/$sheet_filename"; do
        if [[ -f "$sheet_path" ]]; then
            CHEATSHEET="$sheet_path"
            break
        fi
    done

    if [[ -z "$CHEATSHEET" ]]; then
        echo "$sheet_filename not found"
        return 1
    fi

    local preview_cmd='
          echo -e "\033[1mDescription:\033[0m"
          echo {4}
          echo
          echo -e "\033[1mCommand:\033[0m"
          echo -E {3} | bat --language=zsh --color=always --plain'


    # TODO: Not sure what some of these options are.
    local opts="--height ${FZF_TMUX_HEIGHT:-40%} $FZF_DEFAULT_OPTS -n2..,.. --tiebreak=index $FZF_CTRL_R_OPTS +m"

    grep -Ev '^\s*($|#)' "$CHEATSHEET" | \
        tr -s ' ' | \
        bat --color=always --plain --language=zsh | \
        format_cheatsheet_entries | \
        FZF_DEFAULT_OPTS="$opts" fzf --ansi --delimiter='\t' --with-nth=1 --preview-window right:wrap --preview "$preview_cmd" | \
        awk -F'\t' '{print $2}'
}

cheatsheet_widget() {
    local selected
    selected=$(cheatsheet_picker)

    if [[ -n "$selected" ]]; then
        if [[ "$selected" == *"$CURSOR_MARKER"* ]]; then
            # Split at the first occurrence of the marker
            # The second occurrence will be displayed (it's expected to put only one cursor marker).
            local before="${selected%%"$CURSOR_MARKER"*}"
            local after="${selected#*"$CURSOR_MARKER"}"
            LBUFFER+="$before"
            RBUFFER="$after$RBUFFER"
        else
            # No marker, insert normally
            LBUFFER+="$selected"
        fi
    fi
    zle reset-prompt
}
zle -N cheatsheet_widget
bindkey '^F' cheatsheet_widget

