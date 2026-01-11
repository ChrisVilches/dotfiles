# Place it in ~/.oh-my-zsh/custom/themes/

# This is for vim mode (unused)
# export MODE_INDICATOR="%B%K{green}%F{black}NORMAL%b%k%f"
# export MODE_INDICATOR=""
# export INSERT_MODE_INDICATOR="%K{red}%F{black}INSERT%k%f"
# export INSERT_MODE_INDICATOR=""
# export RPROMPT=""

export ZSH_THEME_GIT_PROMPT_PREFIX=" %K{black}%F{green}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%k%f"
export ZSH_THEME_GIT_PROMPT_DIRTY=" %F{yellow}✗%f"
export ZSH_THEME_GIT_PROMPT_CLEAN=""

ret_status="%(?:: %K{black}%F{red}%?)%k%f"
# Add this for vim support \$(vi_mode_prompt_info)
export PROMPT="%K{black}%F{red}%n%k%f %K{black}%F{blue}%m%k%f %K{black}%F{yellow}%~%k%f\$(git_prompt_info)$ret_status
"

export PROMPT2="%B%F{yellow}%_> %k%f%b"
