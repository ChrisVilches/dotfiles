# Input method install (fcitx5)

Instructions for an agent setting up input methods on this machine (Arch Linux, X11, i3 started by `ly`).

Result: fcitx5 with English, Japanese and Chinese input methods. Each one has an i3 keybinding that switches straight to it (no cycling).

Files involved (all in this repo):

- `input-method/fcitx5/` - the whole fcitx5 config directory (`profile` = input method list, `config` = hotkeys/behaviour).
- `i3/config` - starts fcitx5 and holds the switching keybindings (the `fcitx5-remote -s` lines). It is the only place the keys are defined.
- `i3/.xprofile` - exports the environment variables that make apps send input through fcitx5.

## 1. Install packages

```sh
sudo pacman -S --needed fcitx5 fcitx5-gtk fcitx5-qt fcitx5-anthy fcitx5-chinese-addons noto-fonts-cjk
```

`fcitx5-configtool` (GUI) is not needed; configuration is done by editing the files.

## 2. Stop ibus

```sh
pkill ibus-daemon
```

Ask the user before uninstalling the old packages (`sudo pacman -Rns ibus-anthy ibus sunpinyin`).

## 3. Link the config

Symlink the **directory**, not the individual files: fcitx5 saves by writing a temp file and renaming it, which would replace a file symlink with a regular file.

```sh
# Back up an existing real directory first.
[ -d ~/.config/fcitx5 ] && [ ! -L ~/.config/fcitx5 ] && mv ~/.config/fcitx5 ~/.config/fcitx5.bak
ln -s ~/dev/dotfiles/input-method/fcitx5 ~/.config/fcitx5
```

Check that these already point into the repo (create them if not):

```sh
ls -l ~/.config/i3/config ~/.xprofile
# ~/.config/i3/config -> ~/dev/dotfiles/i3/config
# ~/.xprofile        -> ~/dev/dotfiles/i3/.xprofile
```

## 4. Start fcitx5 and let it normalize the config

```sh
fcitx5 -r -d
```

fcitx5 may rewrite the config files with all keys and comments. Check `git diff input-method/` and tell the user what changed, so the normalized version can be committed. In particular, check that the `[Hotkey/...]` sections in `config` are still empty (no `Control+space`, etc.).

## 5. Log out and back in

The environment variables in `~/.xprofile` only apply to a new X session. Ask the user to do this.

## 6. Verify

```sh
fcitx5-diagnose            # no errors about environment variables or IM modules
fcitx5-remote -s anthy && fcitx5-remote -n        # prints: anthy
fcitx5-remote -s pinyin && fcitx5-remote -n       # prints: pinyin
fcitx5-remote -s keyboard-jp && fcitx5-remote -n  # prints: keyboard-jp
```

Ask the user to press each switching key (defined in `i3/config`) and type in Chrome and in a terminal (alacritty/ghostty): `abc`, `あいう`, `你好`.

## Troubleshooting

- A key does nothing: run `xev -event keyboard` and press it to check its keysym name matches the `bindsym` in `i3/config`. keyd (`keyd/default.conf`) may be remapping it.
- Input method name unknown: `fcitx5-remote -s` needs the internal name; list them in `/usr/share/fcitx5/inputmethod/`.
- Debug logs: `fcitx5 -r --verbose '*=5'`.
- Engine settings (Anthy, Pinyin): fcitx5 creates `input-method/fcitx5/conf/anthy.conf` and `conf/pinyin.conf` when they are changed; edit those files and restart with `fcitx5 -r -d`.
