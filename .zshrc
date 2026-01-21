# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# NOTE: Don't use "shellcheck disable=..." as it makes LSP difficult to verify
# whether it's working or not.
# NOTE: Use this Lua code to check the source of diagnostics. Some come from LSP
# and others from the linter, which can be useful for troubleshooting why diagnostics
# aren't being shown (or why they are being shown, etc).
# print(vim.inspect(vim.diagnostic.get(0)))

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
export ZSH_THEME="custom"

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
export plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

source "$ZSH/oh-my-zsh.sh"

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

# Remove the annoying way the exclamation mark is used in zsh (for history expansion).
setopt nobanghist

# Display hidden files in the file completion selection menu. Use fzf-tab to quickly locate files.
setopt GLOB_DOTS

eval "$(fnm env --use-on-cd)"
eval "$(rbenv init - zsh)"
eval "$(zoxide init zsh)"

# Sourced file directory (so it gets /dotfiles folder).
ZSHRC_DIR="${${(%):-%x}:A:h}"

if [[ $- == *i* ]]; then
    source "$ZSHRC_DIR/zle-widgets-fzf.zsh"
    source "$ZSHRC_DIR/zle-widgets.zsh"
fi

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
alias oc='opencode'
e() {
    "$EDITOR" "$@"
}

# Git Status + fzf + read files/diff
gz() {
    git status --porcelain |
    fzf -m |
    while IFS= read -r line; do
        local st file

        st=${line[1,2]}
        file=${line[4,-1]}

        case "$st" in
            M*|*M)
                git diff -- "$file"
                ;;
            '??')
                bat -- "$file" 2>/dev/null || cat -- "$file"
                ;;
        esac
    done
}

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
        local result
        result="$(search-text-ripgrep.sh "$1")"
        if [ -z "$result" ]; then
            return 0
        fi
        local file="${result%%:*}"
        local line="${result#*:}"
        vim "+$line" "$file"
    }
fi

listen() {
    local dir filename
    dir=$(dirname -- "$1")
    filename=$(basename -- "$1")
    watchexec --timings --clear --restart --watch "$dir" --filter "$filename" "$2"
}

listencp() {
    # Try to remove the "data" prefix, if any
    local datafile=${2#data}
    local cmd="c++ $1 < data$datafile | cpdiff -l -d ans$datafile"
    listen "$1" "$cmd"
}

leet() {
    local src="/tmp/leetsrc.cpp"
    local ans="/tmp/leetans"
    local run="c++ $src | cpdiff $ans"
    listen "$2" "leetcode.py $1 $2 $src $ans && $run"
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

n() {
    local prev
    prev="$(pwd)"
    cd ~/memos || return 1

    local init_code='
           require("todos").set_ignored_dirs({ "archived" })
           require("nvim_utils")
    '
    if [ -n "$1" ]; then
        nvim "$1" -c "lua $init_code"
    else
        nvim -c "lua $init_code"
    fi

    bash ./sync-git.sh
    cd "$prev" || return 1
}

qn() {
    cd ~/memos || return 1
    n "quick/$(date '+%Y-%m-%d')-$(date '+%H%M%S').md"
}

# Journal Note
jn() {
    if [[ -z "$1" ]]; then return 1; fi
    cd ~/memos || return 1
    n "journal/$(date '+%Y-%m-%d')-$1.md"
}

# Work Note
wn() {
    if [[ -z "$1" ]]; then return 1; fi
    cd ~/memos || return 1
    n "work/$(date '+%Y-%m-%d')-$1.md"
}

get_unattached_sessions() {
    tmux ls | awk -F':| ' '$NF != "(attached)" {print $1}'
}

