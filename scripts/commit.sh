#!/bin/sh

# Type a commit with the format `git commit -m "[branch-name] message"`

BRANCH=$(git branch --show-current)

if [ -n "$BRANCH" ]; then
  git status

  if [ "$BRANCH" == "main" ]; then
    tmux send-keys "git commit -m \"\"" Left
  else
    tmux send-keys "git commit -m \"[$BRANCH] \"" Left
  fi
else
  return 1
fi

