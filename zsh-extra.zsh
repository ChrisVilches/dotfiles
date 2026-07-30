typeset -g AUTO_ENV_ACTIVE=""
typeset -g AUTO_ENV_PROVIDER=""

# TODO: Works for python (enabling/disabling) but how would I do this for Ruby
# and Node? Disabling it would mean go back to the global/standard version, but
# not sure if fnm and rbenv have that. Just vibecode some solution.

# -----------------------------------------------------------------------------
# Python virtual environments
# -----------------------------------------------------------------------------

__auto_python_venv() {
    local dir="$PWD"

    while [[ "$dir" != "/" ]]; do
        for name in .venv venv env; do
            if [[ -f "$dir/$name/bin/activate" ]]; then
                REPLY="$dir/$name"
                return 0
            fi
        done

        dir="${dir:h}"
    done

    return 1
}

# -----------------------------------------------------------------------------
# Main dispatcher
# -----------------------------------------------------------------------------

auto_env() {
    local found=""
    local provider=""

    #
    # Try each provider.
    #

    if __auto_python_venv; then
        found="$REPLY"
        provider="python-venv"
    fi

    #
    # Nothing changed.
    #

    if [[ "$AUTO_ENV_ACTIVE" == "$found" ]]; then
        return
    fi

    #
    # Deactivate previous environment.
    #

    if [[ -n "$AUTO_ENV_ACTIVE" ]]; then
        printf "🌱 Deactivating %s: %s\n" \
            "$AUTO_ENV_PROVIDER" \
            "$AUTO_ENV_ACTIVE"

        case "$AUTO_ENV_PROVIDER" in
            python-venv)
                (( $+functions[deactivate] )) && deactivate
                ;;
        esac

        AUTO_ENV_ACTIVE=""
        AUTO_ENV_PROVIDER=""
    fi

    #
    # Activate new environment.
    #

    if [[ -n "$found" ]]; then
        printf "🌱 Activating %s: %s\n" \
            "$provider" \
            "$found"

        case "$provider" in
            python-venv)
                source "$found/bin/activate"
                ;;
        esac

        AUTO_ENV_ACTIVE="$found"
        AUTO_ENV_PROVIDER="$provider"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_env

auto_env
