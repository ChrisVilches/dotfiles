# Place it in ~/.oh-my-zsh/custom/themes/ and set ZSH_THEME="custom"

export ZSH_THEME_GIT_PROMPT_PREFIX=" %F{green}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
export ZSH_THEME_GIT_PROMPT_DIRTY=" %F{yellow}✗%f"
export ZSH_THEME_GIT_PROMPT_CLEAN=""

# NOTE: When splitting a pane, the time may be re-rendered in a prompt that has
# already been rendered. As a result, the displayed time may not be accurate in
# all cases. I believe this only occurs when splitting panes and does not
# happen under any other circumstances.

ret_status="%(?:: %F{red}%?%f)"
job_status="%(1j: %F{yellow}•%f:)"
time=$'%F{blue}%D{%H:%M:%S}%f'
#   108     = time (a muted sage green: still a real color, but quiet enough
#             that it does not compete with the rest of the prompt)
# Add this for vim support \$(vi_mode_prompt_info)
export PROMPT="%F{magenta}%n%f %F{cyan}%m%f %F{yellow}%~%f\$(git_prompt_info)$ret_status $time$job_status
"

export PROMPT2="%B%F{yellow}%_> %f%b"
