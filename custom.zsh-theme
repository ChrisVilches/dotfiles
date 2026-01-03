# Put it on ~/.oh-my-zsh/custom/themes/

autoload -Uz add-zsh-hook

# This makes it easy to move vertically in tmux using { and }.
__prompt=0
function print_newline_in_between() {
    if (( __prompt == 1 )); then
        echo
    fi

    __prompt=1
}

# It glitches a bit when executing `clear` or sourcing .zshrc again.
# Clearing using CTRL+L seems to work well.
add-zsh-hook precmd print_newline_in_between

export ZSH_THEME_GIT_PROMPT_PREFIX="%{$bg[black]%}%{$fg[green]%}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
export ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗%{$reset_color%}"
export ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}%{$reset_color%}"

export PROMPT=$'%{$bg[black]$fg[red]%}%n%{$reset_color%} %{$bg[black]$fg[blue]%}%m%{$reset_color%} %{$bg[black]$fg[yellow]%}%~%{$reset_color%} $(git_prompt_info)\n'
export PROMPT2="%{$fg_bold[yellow]%}%_> %{$reset_color%}"

