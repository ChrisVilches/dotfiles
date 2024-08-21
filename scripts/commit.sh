#!/bin/sh

# Type a commit with the format `git commit -m "[branch-name] message"`

BRANCH=$(git branch --show-current)

if [ -n "$BRANCH" ]; then
  git status
  tmux send-keys "git commit -m \"[$BRANCH] \"" Left
else
  return 1
fi

