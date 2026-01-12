# TODO: LSP isn't working on this file and the other widget one.

git_branch_insert() {
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) || branch=$(git describe --tags --exact-match 2>/dev/null) || return
    LBUFFER+="$branch"
}
zle -N git_branch_insert
bindkey '^B' git_branch_insert

git_insert_commit() {
    BRANCH=$(git branch --show-current)

    if [ -z "$BRANCH" ]; then return; fi

    zle -I
    git status

    LBUFFER="git commit -m \""

    if [[ "$BRANCH" != "main" ]]; then
        LBUFFER+="[$BRANCH] "
    fi

    # TODO: Solving the LSP message changes the behavior (it breaks the prompt)
    RBUFFER="\""
}
zle -N git_insert_commit
bindkey '^Xc' git_insert_commit

llm_system_prompt="You are helping a user inside an interactive shell.

Rules:

- The text before the first '#' is a shell command (possibly broken or suboptimal).
- The text after '#' (if present) is the user's intent or explanation.
- Your job is to return a *single improved shell command line* that fulfills the user's intent.
- The result must be valid to paste and execute in a POSIX-like shell.
- Do NOT output plain prose.
- If you need to explain what you changed, add it only as a comment:
  - Either append it after '#' on the same line, or
  - Put it on a new line that starts with '#'.
- Never emit un-commented natural language.
- Never remove the command entirely; always return a command.
- Preserve the original purpose, but fix errors, improve correctness, and apply the user's intent.

Output format:

<improved command>[ # short explanation]
[# optional extra explanation lines]

Only output the command and comments. Nothing else."

_get_user_prompt() {
    cat <<EOF
The user typed this line in their terminal:

$1
EOF
}

_get_llm_model() {
    if [[ -n "$LLM_MODEL" ]]; then
        echo "$LLM_MODEL"
    else
        llm models default
    fi
}

_execute_call() {
    local llm_result tmp_err err

    tmp_err=$(mktemp)
    llm_result=$(llm --model "$2" --system "$llm_system_prompt" "$(_get_user_prompt $1)" 2>"$tmp_err")

    local llm_call_status=$?
    err=$(<"$tmp_err")
    rm -f "$tmp_err"

    if [[ $llm_call_status -ne 0 ]]; then
        echo "$err"
        return 1
    fi

    echo "$llm_result"
}

# Test using a theme with characters in the prompt to ensure proper rendering and resetting.
function llm-fix-command {
    local cmd="$LBUFFER$RBUFFER"

    zle -M "Wait..."
    zle -R

    local llm_model="$(_get_llm_model)"

    zle -M "($llm_model) LLM'ing... ⏳"
    zle -R

    local llm_result
    llm_result="$(_execute_call $cmd $llm_model)"

    if [[ $? -eq 0 ]]; then
        # Position the cursor at the first #. This is useful for removing the comment
        # and adding a new prompt.
        if [[ "$llm_result" == *"#"* ]]; then
            LBUFFER="${llm_result%%#*}#"
            RBUFFER="${llm_result#*#}"
        else
            LBUFFER="$llm_result"
            RBUFFER=""
        fi
        zle -M ""
    else
        zle -M "Error: Command execution failed. $llm_result"
    fi
}

# Tip: you can do "undo" in ZSH to go back to the original command.
zle -N llm-fix-command
bindkey '^X^L' llm-fix-command
