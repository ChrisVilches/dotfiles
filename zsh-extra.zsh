auto_env() {
    #
    # Python virtual environment
    #

    for name in .venv venv env; do
        if [[ -f "$PWD/$name/bin/activate" ]]; then
            source "$PWD/$name/bin/activate"
            printf "🌱 venv: %s\n" "$PWD/$name"
            break
        fi
    done

    #
    # Node (fnm)
    #

    if [[ -f "$PWD/.nvmrc" ]]; then
        fnm use
    fi

    #
    # Ruby (rbenv)
    #

    if [[ -f "$PWD/.ruby-version" ]]; then
        rbenv local "$(<"$PWD/.ruby-version")"
        printf "rbenv: %s\n" "$(rbenv version)"
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd auto_env

auto_env
