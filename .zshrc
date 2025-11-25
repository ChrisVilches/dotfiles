# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="jispwoso"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Put here things that cannot be committed (private keys, private IPs, etc).
[[ -f ~/.zshrc.private ]] && source ~/.zshrc.private

eval "$(fnm env --use-on-cd)"
eval "$(rbenv init - zsh)"
eval "$(zoxide init zsh)"

# Sourced file directory (so it gets /dotfiles folder).
ZSHRC_DIR="${${(%):-%x}:A:h}"

source $ZSHRC_DIR/fzf-key-bindings.zsh

PATH=$ZSHRC_DIR/scripts:$PATH
PATH=~/go/bin:$PATH
alias cpy='xsel -b'
alias gs='git status'
alias gd='git diff'
alias ga='git add --patch'
alias gl='git log --patch'
alias ll='ls -alF --block-size=MB --color=always'
alias la='ls -A'
alias l='ls -CF'
alias lll='ll | less -R'
alias e=$EDITOR

git_branch_insert() {
  local branch
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || branch=$(git describe --tags --exact-match 2>/dev/null) || return
  LBUFFER+="$branch"
}
zle -N git_branch_insert
bindkey '^B' git_branch_insert

if [[ -n $SSH_CONNECTION ]]; then
  st() {
    if [ -z "$1" ]; then
      return 0
    fi

    grep \
    --exclude-dir={.git,tmp,log,deps,node_modules,vendor,dist,build,target,,_build,.ipynb_checkpoints} \
    -r "$1" .
  }
else
  st() {
    local result="$(search-text-ripgrep.sh "$1")"
    if [ -z "$result" ]; then
      return 0
    fi
    local file="${result%%:*}"
    local line="${result#*:}"
    vim +$line $file
  }
fi

# Troubleshooting: When nodemon stops working, sometimes it's because Neovim/vim starts emitting
# the "unlink" event, and after that no change event will be captured by nodemon. Kinda weird.
# This can be fixed by changing neovim settings using:
# :set nowritebackup
# However I'm not sure if this disables some nice useful Neovim features.
# Nodemon works OK with one --watch <file> though (the issue above happens with multiple files).
# Note that chokidar also has this same problem when using two files. Maybe it's OS related.
# (chokidar also lacks the functionality that kills the previous execution, so I can't use it)

listen() {
  npx nodemon --watch $1 --exec $2
}

listencp() {
  # Try to remove the "data" prefix, if any
  local datafile=$(echo $2 | sed 's/^data//g')
  local cmd="c++ $1 < data$datafile | cpdiff -l -d ans$datafile"
  listen $1 "$cmd"
}

leet() {
  listen $2 "leetcode.rb $1 $2 /tmp/leetsrc.cpp /tmp/leetans && c++ /tmp/leetsrc.cpp | cpdiff /tmp/leetans"
}

pacman-size() {
  LC_ALL=C.UTF-8 pacman -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | LC_ALL=C.UTF-8 sort -h
}

# randtime <start_hour> <end_hour>
# Generates a random time in HH:MM:SS format.
# Arguments:
#   start_hour - the first hour (0–23) of the range
#   end_hour   - the last hour (0–23) of the range
randtime() {
  local start_hour=$1
  local end_hour=$2
  if [[ -z $start_hour || -z $end_hour || $start_hour -gt $end_hour ]]; then
    echo "Usage: randtime <start_hour> <end_hour>" >&2
    return 1
  fi
  hour=$((RANDOM % (end_hour - start_hour + 1) + start_hour))
  min=$((RANDOM % 60))
  sec=$((RANDOM % 60))
  printf "%02d:%02d:%02d\n" "$hour" "$min" "$sec"
}

export TERM_KEEP_DB_PATH=~/.term-keep.db
export TERM_KEEP_SUMMARY_MAX_LENGTH=100

tk() {
  # Randomize this variable so I can test both with logo and without.
  export TERM_KEEP_HIDE_LOGO=$((RANDOM % 2))
  term_keep "$@"
}

n() {
  local prev="$(pwd)"
  cd ~/memos
  nvim && bash ./sync-git.sh
  cd "$prev"
}

# Quick Note (memo)
qn() {
  cd ~/memos
  bash add-quick.sh
}

# Journal Note
jn() {
  cd ~/memos
  bash add-note.sh journal "$@"
}

# Work Note
wn() {
  cd ~/memos
  bash add-note.sh work "$@"
}

# TODO: This is for getting started using fzf in a custom way that matches my workflow.
# Find and edit

# TODO: Try something like this too: git branch | fzf | xargs git checkout
# (list all branches, find using fuzzy search, then checkout to that one).
#
# TODO: Another pretty good one git log --oneline | fzf | awk '{print $1}' | xargs git show
# TODO: More stuff: git status | grep modified | fzf -m | awk '{print $2}' | xargs git diff
# allow "newly created files" too, and use different commands (git diff for modified, and cat for new)

# NOTE: This didn't work with an older version of tmux. Verified it works with version `tmux next-3.5`
#       (older versions don't set this env variable).
if [ "$TERM_PROGRAM" = "tmux" ]; then
  # Get the first unattached session, if any.
  first_unattached_session=$(tmux ls -F '#{session_attached} #{session_name}' 2> /dev/null | grep ^0 -m 1 | cut -c3-)

  # If there's an unattached session, attach that one.
  if [ -n "$first_unattached_session" ]; then
    exec tmux switch -t $first_unattached_session
  fi
fi

