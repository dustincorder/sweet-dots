# Workflows

## Install / re-apply (user machine)

```sh
./install.sh        # asks language (ru/en) + workspaces (2/3/4)
```

Backs up replaced files under `$HOME/.local/state/sweet-dots/backups/<ts>/`,
copies `dotfiles/` (expanding `@HOME@` only), seeds
`$HOME/.local/share/sweet-dots/templates/`, runs
`settings.py --setup`. Then choose **Niri** on the login screen; the
previous session stays available.

Settings-rendered targets are skipped during the raw copy pass, so a live
Niri session never briefly receives unexpanded `@WORKSPACE_*@` templates.

Run the installer as the target user with that user's `$HOME`.
If the agent itself runs as root, scope the call down — never deploy
with root's environment:

```sh
runuser -u <target-user> -- env HOME=<target-home> ./install.sh
```

Same for everything user-scoped (`settings.py`, `systemctl --user`,
`gh`, wallpaper/matugen runs): `runuser -u <target-user> -- env
HOME=<target-home> XDG_RUNTIME_DIR=/run/user/<uid> ...`. Then verify
ownership (`stat -c '%U %n'` on a deployed file) — root-owned files in
a user home break the session. A wrong `$HOME` deploys into the wrong
home — see `TROUBLESHOOTING.md`.

## Change panel / widgets / shortcuts / language

GUI: `python3 ~/.config/niri/scripts/settings.py`
(or launcher entry, or `Mod+Shift+S`). Three tabs: General
(language, workspaces, position, sizes, clock date), Dock and widgets
(left/center/right groups, add/remove/reorder, built-in widgets + custom
shortcut widgets), Custom shortcuts (label/key/command/icon, validated:
non-empty label+command, key `[A-Za-z0-9_+-]+`, unique).

Headless equivalents:

```sh
python3 ~/.config/niri/scripts/settings.py --setup --language ru --workspaces 2
python3 ~/.config/niri/scripts/settings.py --refresh-style  # widget scale only
```

`apply()` writes `settings.json`, renders all `TARGETS`, backs up to
`~/.local/state/sweet-dots/settings-backups/<ts>/`, reloads niri config,
signals a running Waybar or starts it directly, and reloads swaync
config+css. No separate Waybar user unit is required.

## Change wallpaper / theme

`Mod+Shift+W` or `python3 ~/.config/niri/scripts/wallpaper.py`.
Picks from `$HOME/.local/share/niri/wallpapers/` (png/jpg/webp/avif),
symlinks `current.jpg`, regenerates the fastfetch portrait, runs matugen
(dark `scheme-content`), refreshes widget scale, reloads
niri + swaync + waybar. See `skills/wallpaper-theming/SKILL.md`.

## Validate (run before finishing any change)

```sh
git diff --check
python3 -m py_compile <touched scripts>.py
niri validate   # or: niri msg action load-config-file
```

Live reloads: `pkill -USR2 -x waybar`, `swaync-client --reload-config`,
`swaync-client --reload-css`, `swaync-client --toggle-panel` (smoke test).

## Add wallpapers from local sources

`prepare-wallpapers.sh` / `prepare-fastfetch-logo.py` build the optional
local pack from user-supplied image directories (env-overridable path).
Sources and outputs stay on the machine — never commit them
(`wallpapers/*` is git-ignored by design).
