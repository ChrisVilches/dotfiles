# Put it on ~/.oh-my-zsh/custom/themes/

export ZSH_THEME_GIT_PROMPT_PREFIX=" %{$bg[black]%}%{$fg[green]%}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
export ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%} %{$fg[yellow]%}✗%{$reset_color%}"
export ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%}%{$reset_color%}"

local ret_status="%(?:: %{$bg[black]$fg[red]%}%?)%{$reset_color%}"
export PROMPT=$'%{$bg[black]$fg[red]%}%n%{$reset_color%} %{$bg[black]$fg[blue]%}%m%{$reset_color%} %{$bg[black]$fg[yellow]%}%~%{$reset_color%}$(git_prompt_info)$ret_status\n'
export PROMPT2="%{$fg_bold[yellow]%}%_> %{$reset_color%}"

