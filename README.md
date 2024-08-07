# Configs

## Neovim

Working Neovim version:

```sh
nvim -v
NVIM v0.10.1
```

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

In order to start TMUX automatically, just configure the launchers (desktop icons and keyboard shortcuts) to include an `exec` of the `tmux` command. The main requirement is that the process is replaced by `tmux` (instead of becoming a nested shell).

Note that the `xfce4-terminal` has a weird focusing behavior after it's launched (the window doesn't get automatically focused, and I can't type) which makes it useless for me, so I decided to try other terminals.

Setup a custom shortcut using `CTRL+ALT+T` (e.g. in Gnome):

| Terminal name | Transparency | Focusing | Launcher
| --- | --- | --- | --- |
| Terminator | ✅ | ✅ | terminator -x tmux |
| Gnome Terminal | ❌ | ✅ | gnome-terminal -- bash -c "exec tmux" |
| xfce4-terminal | ✅ | ❌ | (Don't use) |

## Keyd

Keyboard mapping.

Install `keyd`, then put the config file where it should go.

Remember to enable the service.
