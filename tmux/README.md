# tmux config and themes

This folder has the tmux config and a small theme system. Each theme is a file
of colours (data only), and `theme.sh` generates the tmux options from it, so
all themes share one layout and differ only in their data.

The two sections that matter most are
[Creating or editing a theme](#creating-or-editing-a-theme) and
[Pitfalls for agents](#pitfalls-for-agents).

## Files

| File | Role |
|---|---|
| `tmux.conf` | Main config. `~/.tmux.conf` is a symlink to it. |
| `theme.sh` | Builds and applies themes, and creates the menu. All the logic is here. |
| `theme-NAME.sh` | One theme: bash variable assignments, nothing else. |
| `current-theme.conf` | Generated, gitignored. The built config of the theme that was picked. |
| `.gitignore` | Ignores `current-theme.conf`. |

## How it fits together

### At tmux startup

`tmux.conf` resolves its own folder through the `~/.tmux.conf` symlink
(`readlink -f`; `#{d:current_file}` would give `~`, because `current_file` is
the symlink) and runs `theme.sh --init` from it. That:

- binds prefix T to the menu (see below);
- unsets the options and sources `current-theme.conf`, the same way as picking
  a theme but without building it again. Without the file, tmux keeps its
  default look.

`run` without `-b` waits for the script, so the rest of `tmux.conf` loads after
the theme.

### Picking a theme (prefix T, or `theme.sh NAME` from a shell)

`theme.sh NAME`:

1. Exits with an error if `theme-NAME.sh` doesn't exist.
2. Runs `build NAME` inside `$(...)`. If that fails, it exits without touching
   anything, so the current theme stays.
3. Writes the result to `current-theme.conf`.
4. Sends one piece of config to `tmux source-file -` on stdin: `set -gu` for
   every option in the `options` array, then the new config. Since it's a single
   `source-file`, tmux doesn't redraw in between, so the default look never
   flashes.

`theme.sh` with no argument removes `current-theme.conf` and only unsets the
options, which gives tmux's built-in look. The menu's `tmux` item (key `t`)
does this.

### Why everything gets unset first

Themes `set -g` options, which overwrite tmux's global values, and loading
another theme doesn't undo that. If theme A set an option that theme B doesn't,
A's value would stay. So `theme.sh` unsets everything in `options` before
applying B. That's also why a forgotten colour can't carry over from the
previous theme: `theme.sh` is a new process each time, and every option starts
from tmux's default.

### The menu

It goes through `theme-*.sh` in glob (alphabetical) order. It sources each file
in a subshell to read its `menu_key`, then calls `tmux bind T display-menu …`,
with a final `tmux` item under `t` for the default look. It only runs when the
config loads, so a new theme file appears in the menu after reloading
`tmux.conf` or restarting tmux.

## How `build()` works

`build NAME` sets defaults for the optional settings, sources `theme-NAME.sh`,
checks that the required colours aren't empty, and prints tmux config. The list
of settings is in the comment above `build()` in `theme.sh`, which is the
reference. Summary:

**Required** (checked; a missing one stops with `theme-NAME.sh doesn't set X`):
`bar_bg bar_fg program_fg program_bg program_prefix_bg window_fg current_fg
current_bg border_fg label_fg label_active_fg message_bg message_fg command_bg
command_fg mode_bg`

**Optional** (default in brackets):

| Setting | Meaning |
|---|---|
| `menu_key` | Key in the prefix T menu. Read for the menu, not by `build()`. |
| `shape` | `block` (padded blocks, the default) or `pill` (rounded ends, needs a Nerd Font). |
| `bold` | `yes` (default) or `no`. Applies to the program block, current window and active pane label. |
| `zoom` | Marker after a zoomed window's path [`[Z]`]. Themes can use `$zoom_arrow`. |
| `border_lines` | `pane-border-lines` value [`single`]. |
| `label_active_bg` | Background of the active pane label [none]. |
| `current_marker`, `current_marker_fg` | Text drawn in place of the current window's left padding (block shape only), e.g. vampire's red bar. |
| `window_colors` | Bash array of colours. The generator writes `@window_color`, a lookup by window ID modulo the array length. |
| `activity_style`, `bell_style`, `clock_color` | Emitted only when set. |

What the output contains:

- **Status bar**: bar style and the program block on the
  right (`#{pane_current_command}`). The program block's background is
  `#{?client_prefix,PREFIX_BG,BG}` inside its style, so it changes colour while
  the prefix key is pressed.
- **Window tabs**: inactive windows are coloured text, and the current window
  is a block or pill. Each shows the window's name if it was renamed (prefix
  `,` or `rename-window`, which turns `automatic-rename` off for that window),
  or else its path with `$HOME` shortened to `~`, plus the zoom marker. Running
  `tmux set -w automatic-rename on` in a window brings its path back. Renaming
  it to an empty name doesn't, because that still counts as a rename. Inactive windows keep the same width as the current one, so the
  list doesn't shift when switching.
- **Pane labels** (`pane-border-format`): `#P: path`, centred, with the active
  one highlighted.
- **Messages, command prompt, copy-mode selection** (`message-style`,
  `message-command-style`, `mode-style`).

### Colour values

A colour is anything tmux accepts as a colour: `#rrggbb`, ANSI names like `blue`
or `brightblack` (minimal uses only these, so it follows the terminal's
palette), or a tmux format that expands to a colour. Pastel uses
`'#{E:@window_color}'` for the per-window colour.

## Creating or editing a theme

1. Copy an existing `theme-*.sh`. Use graphite for a block theme, dusk for
   pills, pastel for per-window colours.
2. Set every required colour, and a `menu_key` that no other theme uses and
   that isn't `t` (taken by the default-look item).
3. Start the file with a comment describing the theme's idea. The other themes
   do this.
4. Apply it with `./theme.sh NAME` and look at it. It needs a reload
   (`tmux source-file ~/.tmux.conf`) before it shows up in the menu.
5. After editing an existing theme, apply it again. `current-theme.conf` is a
   copy made at apply time, and restarting tmux loads that copy, not the
   edited file.

Things to be careful about:

- **Theme files are sourced by bash.** Put colours in single quotes
  (`'#111111'`, `'#{E:@window_color}'`), so bash leaves `#`, `{` and `$` alone.
  `$zoom_arrow` is the exception: it's a variable from `theme.sh`, so it must
  not be single-quoted.
- **A theme file must only assign variables.** It's sourced once by `build()`
  and once for the menu (at every tmux start), so commands in it would run both
  times.
- **Misspelled settings aren't caught.** `bar_gb='#111'` is silently ignored. If
  it was meant to be a required setting, the check reports the correct name as
  missing. If it was an optional one, the default is used without any warning.
- **Colour values aren't validated.** A bad colour in a style option
  (`status-style`, `message-style`, …) makes tmux print `invalid style` and keep
  its default. In a format (`status-right`, window formats, pane label) it's
  ignored silently.

## Changing `build()` (the shared layout)

- **Any new option that `build()` sets must be added to `options`**, or it will
  carry over into themes that don't set it, and into the default look.
- **New required settings** go in the check's list. Optional ones get a
  default at the top of `build()`. Also update the settings comment above
  `build()` and the table in this README.
- **Commas inside `#{?cond,a,b}`** separate the branches, so a style inside a
  branch must write its commas as `#,` (see `pane-border-format`). Commas in a
  `#[…]` outside a condition are fine.
- **`$HOME` in the path format** is written literally into the config
  (`path='#{s|^$HOME|~|:pane_current_path}'`, single-quoted). tmux expands
  `$HOME` itself when it parses the double-quoted option value. Keep it in
  single quotes in bash.
- **Don't put `#(command)` in any status format.** It starts a shell every
  `status-interval` (5 s, set by tmux-sensible), which is the usual cause of
  tmux using CPU. Everything in the formats now is evaluated inside tmux and
  is cheap.
- **The two shapes have separate templates** for the program block and the
  current window. Changes to either piece usually need doing in both branches.

## Pitfalls for agents

- **Your editing tools may drop Nerd Font glyphs.** The pill ends (U+E0B6,
  U+E0B4) and the zoom arrow (U+F004C) are Private Use Area characters, and
  writing them through an edit or write tool has been seen to silently remove
  them. That's why `theme.sh` defines them as UTF-8 byte escapes
  (`$'\356\202\266'`). Don't type these glyphs into files. To check bytes, use
  something like
  `perl -CSD -ne 'while(/([^\x00-\x7f])/g){printf "U+%04X\n", ord $1}' FILE`.
- **Test against a separate tmux server, not the user's session.**
  `theme.sh` calls plain `tmux`, so put a wrapper first on `PATH`:
  `printf '#!/bin/sh\nexec /usr/bin/tmux -L theme-test "$@"\n' > bin/tmux`,
  start it with `tmux -f /dev/null new -d`, and `tmux kill-server` when done.
  `TMUX_TMPDIR` pointing at a deep scratch directory fails with
  `File name too long`, because Unix socket paths are limited to about 108
  bytes. Note that `theme.sh` still writes `current-theme.conf` in this folder,
  so apply the user's theme again afterwards (`readlink`/`cat` it first to see
  which one it was).
- **zsh doesn't word-split `$var`.** Loops like `for o in $opts` over a
  space-separated list run once with the whole string. Run such snippets with
  `bash -c` (the scripts here are bash).
- **To compare a refactor of `build()`**, dump `tmux show -g OPTION` for every
  option in `options`, before and after, on the test server, and diff them.
- **Inspect the rendered result** with `tmux display -p '#{T:status-right}'`
  (or another option). Without an attached client, `client_prefix` is false.

## Known limitations

- `current-theme.conf` can be stale after editing a theme file or `build()`,
  until the theme is applied again (see above). This was accepted because
  themes rarely change.
- The menu is rebuilt only when the config loads.
- Menu order is alphabetical by file name.
- Theme names and the folder path are put inside single quotes in the menu's
  `run '…'` commands, so a name or path containing `'` or spaces would break.
- Pills and `$zoom_arrow` need a Nerd Font in the terminal.
- tmux's own default look (no theme) is whatever this tmux version uses
  built in. The theme system doesn't define it.
- No check for misspelled settings or invalid colour values (see above).

## Other parts of `tmux.conf` that interact with themes

- `pane-active-border-style "#{pane-border-style}"`: the active pane's border
  uses the theme's border colour, so only its label stands out.
- A `window-layout-changed` hook turns `pane-border-status` on (top) only when
  a window has more than one pane, so the pane labels from
  `pane-border-format` only appear then. It uses `if-shell -F`, which checks a
  format without starting a shell.
- `status-left` is set in `tmux.conf`, not by the themes: a white on red
  `detached: NAME…` block while any session has no client attached, and empty
  otherwise. Its colours are hardcoded, background included, so it doesn't
  depend on the theme's bar colour. It looks the same in every theme and in tmux's default look.
  It isn't in `options`, so applying a theme leaves it alone.
