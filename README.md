# Configs

## Neovim

1. https://github.com/BurntSushi/ripgrep
2. https://github.com/sharkdp/fd
3. Install Nerd Font
4. Do `healthcheck`
5. Do `MasonInstallAll`

May need some global dependencies that have to be installed manually, so just read the errors.

## Tmux

1. Setup https://github.com/tmux-plugins/tmux-yank
2. Install the defined plugins (check: https://github.com/tmux-plugins/tpm)

## Terminal (ZSH - Oh My Zsh)

Now it doesn't automatically load TMUX by default.

In order to start TMUX automatically, just configure the launchers (desktop icons and keyboard shortcuts) to include an `exec` (`fork`) of the `tmux` command. The main requirement is that the process is replaced by `tmux` (instead of becoming a nested shell).

## Input Remapper

https://github.com/sezanzeb/input-remapper

Setup the `systemctl` service. Use the files in the `input-remapper` folder as presets.

As of now the location where the file should be is (example):

```
~/.config/input-remapper-2/presets/Logitech\ MX\ Keys/escape-and-arrows.json
```

