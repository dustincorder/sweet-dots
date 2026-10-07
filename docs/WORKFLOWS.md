# Workflows

## Install / re-apply (user machine)

```sh
./install.sh        # asks language (ru/en) + workspaces (2/3/4)
```

Checks GitHub main (8-second timeout; no automatic pull), explains overwrites
and asks consent. `--yes` skips consent; `--skip-update-check` is for offline
installs. Refuses root deployment: use the target user. Backs up replaced files under `$HOME/.local/state/sweet-dots/backups/<ts>/`,
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
(or launcher entry, or `Mod+Shift+S`). GTK3 interface styled from the same Matugen palette as the bar, with a live
layout preview. Three tabs: General
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
calls the Waybar supervisor for reload and crash recovery, and reloads swaync
config+css. No separate Waybar user unit is required.

## Change wallpaper / theme

`Mod+Shift+W` or `python3 ~/.config/niri/scripts/wallpaper.py`.
Picks from `$HOME/.local/share/niri/wallpapers/` (png/jpg/webp/avif),
runs Matugen (dark `scheme-content`, rollback on failure), applies the
wallpaper and `current.jpg` symlink, regenerates a transparent fastfetch
portrait, refreshes widget scale, reloads
niri + swaync + waybar. See `skills/wallpaper-theming/SKILL.md`.

## Validate (run before finishing any change)

```sh
git diff --check
python3 -m py_compile <touched scripts>.py
niri validate   # or: niri msg action load-config-file
```

Live reloads: `python3 ~/.config/niri/scripts/panel.py --reload`, `swaync-client --reload-config`,
`swaync-client --reload-css`, `swaync-client --toggle-panel` (smoke test).

## Add wallpapers from local sources

`prepare-wallpapers.sh` / `prepare-fastfetch-logo.py` build the optional
local pack from user-supplied image directories (env-overridable path).
Sources and outputs stay on the machine — never commit them
(generated outputs stay outside git; bundled images are user-approved).

## Restore a missing panel / inspect a crash

Inside the target user's Niri session:

```sh
python3 ~/.config/niri/scripts/panel.py --reload
tail -n 80 ~/.local/state/sweet-dots/waybar.log
```

The supervisor adopts an existing Waybar, starts it if missing and recovers
exits. Three rapid failures stop recovery; fix the error in the log and run
it again. It removes only the current user's duplicate `nm-applet` and
Blueman presentation processes inside Niri, leaving the network/BlueZ
services and the rest of the tray available. Autostart overrides exclude
these two applets from Niri on subsequent logins.

Network/Bluetooth/audio left-clicks open separate GTK layer-shell controls.
Clicking the same button again, Escape, focus loss or × closes its overlay;
opening another closes the previous one. The clock closes controls and
opens only calendar/full date, notifications and media. All overlay gaps
follow the panel height and position.

## Screenshot editing

`Print`: freeze the focused display before selection. A left click without
drag captures that entire display; drag crops the frozen frame; Escape
cancels. Swappy then opens with its tools visible (arrows, text, shapes,
blur, undo). `Ctrl+S` saves, `Ctrl+C` copies. `Shift+Print` skips selection.
Closing without saving leaves no screenshot file. Saved images are copied
with `wl-copy` after the editor exits; multi-display capture uses the
focused display, not a stretched image of the entire desktop.

## Repository checks and review

```sh
python3 -m unittest discover -s tests -v
```

Tests use temporary homes. Verify GUI and layer-shell interactions in Niri
before declaring the PR fixed; publish only when requested, and confirm
live behavior before merge.
See `docs/PR-REVIEW.md` for the manual review sequence.
