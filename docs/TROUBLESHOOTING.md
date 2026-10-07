# Troubleshooting (recurring pitfalls)

## Installer wrote to the wrong home

Symptom: deployed files appear under another `$HOME` (e.g. root's) while
the user session is unchanged. Cause: `install.sh`/`settings.py` use
`$HOME` and `Path.home()` — the environment decides the target, not the
repo. Fix: run as the target user, or from root scope down with
`runuser -u <target-user> -- env HOME=<target-home> ...`. Verify with
`stat -c '%U %n'` on a deployed file and `cat
~/.config/sweet-dots/settings.json`. Root-owned files in a user home
break the session — fix ownership, don't just re-copy.

## SwayNC edits seem to have no effect

SwayNC reads the DEPLOYED config+css (`~/.config/niri/swaync/`), not the
repo templates. Check `swaync-client --reload-config/--reload-css` ran,
and that no stale copy shadows the deployed path. Same class of bug:
style generated into a directory the live session doesn't read.

## Matugen theme looks wrong (near-black / blue tint)

`source_color_index` picks the seed color; a near-black wallpaper yields
a near-black palette. Prefer the second prominent color for dark themes.
Matugen failures surface via desktop notification from `wallpaper.py` —
read it before re-running blindly. After matugen, `wallpaper.py`
refreshes widget scale and reloads niri/swaync/waybar; skipping those
leaves a half-applied theme.

## Blur hits whole layers instead of cards

Niri `background-effect { blur }` window rules apply per matched surface.
A rule matching an entire layer-shell surface (panel/notification layer)
blurs the whole screen region behind it. Scope blur to app-ids
(terminals, launcher, floating windows), never to the panel or
notification layers.

## Rofi launcher won't confirm / won't close

`rofi -show drun` needs explicit `-kb-accept-entry` / `-kb-cancel` in
this setup, plus `-no-lazy-grab`. If selection does nothing, check the
spawn command in `bindings.kdl` first, then the theme's
`display-drun`/`display-run` labels (they are `@UI_@`-localized by
`settings.py`).

## Clipboard provider mismatch

Live chain: `wl-paste --watch cliphist store` (spawned by niri) →
`cliphist list` → rofi → `cliphist decode | wl-copy`. Testing clipboard
outside the compositor session (no Wayland socket / wrong user) fails
even when the config is correct — verify inside the Niri session.

Image rows in the clipboard picker include generated PNG thumbnails under
`$XDG_CACHE_HOME/sweet-dots/clipboard-previews` (or `~/.cache/...`).
Selecting one writes the original bytes back with the `image/png` MIME
type; the preview is a cache and can be regenerated or removed.

## Keybinding conflicts

`@CUSTOM_BINDS@` keys must match `[A-Za-z0-9_+-]+` and be unique.
Overlapping a compositor-reserved or desktop-global binding silently wins
elsewhere (e.g. a DE-global shortcut swallowing the key before Niri sees
it). `settings.py` validates format+uniqueness; scope conflicts still
need a manual check against the session's global shortcuts.

## Niri rejects hot reload after a crash scare

First run `niri validate` — most "crashes" here were config errors
blocking reload while the compositor kept running with the last good
config. Check which config the session actually loaded before assuming
the file on disk is live.

The installer must skip settings-rendered targets during its raw copy
pass. Otherwise Niri can observe unexpanded `@WORKSPACE_*@` placeholders
before `settings.py` replaces them. Waybar is reloaded by signal and
recovered by `panel.py` when absent; do not assume a `niri-waybar.service` unit.

## Fastfetch shows half a logo / pixel soup

The logo must be a full-resolution PNG portrait
(`fastfetch-portrait.png`, `type: auto`), not an ANSI/sixel render
downscaled to a character grid. The portrait is regenerated per wallpaper
by `prepare-fastfetch-logo.py`; deleting the stale `.ansi` artifact is
part of install.

If the wallpaper picker fails before opening, check the traceback from
`wallpaper.py`; keep the wallpaper directory path and translated wallpaper
labels in separate variables so one cannot shadow the translation table.

## Recorded MP4 has no `moov` atom

The recorder must receive `SIGINT` and exit before an MP4 is usable.
Read only the first line of `niri-wf-recorder.pid` as the PID (the second
line is the target path), wait for exit, then verify with `ffprobe` before
showing a success notification. The Waybar recording indicator uses the
same PID file and is clickable to stop safely.

## Duplicate Ethernet/Bluetooth tray icons

`ignored-items` was never a Waybar tray option. Current upstream `master`
documents filters that released Waybar 0.15 does not implement. The portable
fix excludes NM/Blueman applets via Niri-specific autostart overrides and
stops only the current user's presentation processes in `panel.py` when
`NIRI_SOCKET` is set. NetworkManager and BlueZ stay running. Install the
changed files and call `panel.py --reload` in Niri; inspect other custom
autostart entries if an applet is explicitly restarted by a local service.

## Missing Waybar after changing wallpaper

Recover using `python3 ~/.config/niri/scripts/panel.py --reload`. Look at
`~/.local/state/sweet-dots/waybar.log` (or `$XDG_STATE_HOME/sweet-dots/waybar.log`).
The supervisor stops after three rapid failures rather than looping forever.
`wallpaper.py` rolls back a partial Matugen failure before any reload;
CSS scale changes use atomic file replacement. The exact old crash still
requires the affected user's log and package versions.

## GTK controls fail to import

Install `python-gobject`, `gtk3`, `gtk-layer-shell` on Arch. Screenshot
selection also requires `python-cairo`; editing requires `swappy`.
Settings can be smoke-tested under Xvfb; layer-shell controls and screen
capture require the actual Niri session.

## Blue rectangle behind Fastfetch in a warm theme

Re-run `prepare-fastfetch-logo.py` for the current wallpaper. Portraits
now preserve transparency and use bundled sprites if `SWEET_POOL_CG_DIR`
is unset. The old generator filled the canvas with `#101820`, independently
of Matugen. Terminals continue to supply the generated theme background.
