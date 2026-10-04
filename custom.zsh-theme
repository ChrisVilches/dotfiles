# Place it in ~/.oh-my-zsh/custom/themes/ and set ZSH_THEME="custom"

export ZSH_THEME_GIT_PROMPT_PREFIX=" %F{green}"
export ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
export ZSH_THEME_GIT_PROMPT_DIRTY=" %F{yellow}✗%f"
export ZSH_THEME_GIT_PROMPT_CLEAN=""

# NOTE: When splitting a pane, the time may be re-rendered in a prompt that has
# already been rendered. As a result, the displayed time may not be accurate in
# all cases. I believe this only occurs when splitting panes and does not
# happen under any other circumstances.

ret_status="%(?:: %B%F{red}%?%f%b)"
job_status="%(1j: %F{yellow}•%f:)"
time=$'\x1b[2m%D{%H:%M:%S}\x1b[22m'

# Add this for vim support \$(vi_mode_prompt_info)
export PROMPT="%F{magenta}%n%f %F{cyan}%m%f %F{yellow}%~%f\$(git_prompt_info)$ret_status $time$job_status
"

export PROMPT2="%B%F{yellow}%_> %f%b"

# Show worktree information.
# Modifies the original function called by the git plugin and adds the data.
functions -c _omz_git_prompt_info _omz_git_prompt_info_orig
function _omz_git_prompt_info() {
  local out
  out="$(_omz_git_prompt_info_orig)"
  [[ -n "$out" ]] || return 0

  local -a dirs
  dirs=("${(@f)$(__git_prompt_git rev-parse --git-dir --git-common-dir 2>/dev/null)}")
  if (($#dirs == 2)) && [[ "$dirs[1]" != "$dirs[2]" ]]; then
    out+=" %F{magenta}󰙅 ${dirs[1]:t}%f"
  fi

  echo -n "$out"
}
