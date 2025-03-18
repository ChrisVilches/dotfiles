#!/bin/bash

remove-empty-lines() {
  sed -i '/^\s*$/d' $1
}

ID="$(date '+%b%d-%H%M%S')"
DIR="/tmp/term-captures"
mkdir -p $DIR
FILE="$DIR/$ID"
SCROLL_DOWN="lua vim.schedule(function() vim.cmd('normal! G') end)"
EDITOR="nvim -c \"$SCROLL_DOWN\""

tmux capture-pane -S -1000
tmux save-buffer $FILE

remove-empty-lines $FILE

tmux split-window -h "cd $DIR && $EDITOR $FILE"
