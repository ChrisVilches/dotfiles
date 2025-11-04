#!/bin/sh
# TODO: After committing the content changes, make another commit but
# changing the script name (neovim -> editor) since now it's generic
# and accepts vim too (and it's a bit faster).

trim-empty-lines() {
  local remove_leading='/./,$!d'
  local content=$(cat $1)
  echo "$content" | sed "$remove_leading"| tac | sed "$remove_leading" | tac > $1
}

ID="$(date '+%b%d-%H%M%S')"
DIR="/tmp/term-captures"
mkdir -p $DIR
FILE="$DIR/$ID"
# NVIM_SCROLL_DOWN="lua vim.schedule(function() vim.cmd('normal! G') end)"
# EDITOR="nvim -c \"$NVIM_SCROLL_DOWN\""
EDITOR="vim -c 'normal! G'"

tmux capture-pane -S -1000
tmux save-buffer $FILE

trim-empty-lines $FILE

tmux split-window -h "cd $DIR && $EDITOR $FILE"
tmux resize-pane -Z
