# Skill: apply-settings

Triggers: change panel, widget, keybinding, shortcut, language, workspace
count, dock position/size, clock format.

## Do

1. Edit the TEMPLATE (`dotfiles/.../*.tmpl`) or `settings.py.tmpl`
   (`WIDGETS`, `TEXT`, `DEFAULT_GROUPS`, `TARGETS`, `render()` values).
   Never hand-edit deployed outputs (`~/.config/...`) except for a live
   smoke check — then port back.
2. New widget: register in `WIDGETS` (both languages) + waybar module
   block in `config.jsonc.tmpl` + rules in BOTH style templates
   (`style.css.tmpl` for hand-tuned fallback, `style.template.css.tmpl`
   for matugen). New shortcut: goes through `shortcuts[]` (validated).
3. Re-render: `settings.py --setup` or the GUI Apply. Check
   `~/.config/sweet-dots/settings.json` reflects the choice.
4. Validate: `niri validate`, `git diff --check`. Reload waybar/swaync
   (see `docs/WORKFLOWS.md`).

## Don't

- Add a placeholder without handling it in `render()` + the
  leftover-check regex + `docs/TEMPLATING.md`.
- Duplicate a widget across groups (rejected) or reuse a shortcut key
  (rejected, case-insensitive).
- Localize into one language only. Every string needs `ru`+`en`.

## GTK controls and released Waybar compatibility

Settings now use GTK3 (`settings_gui.py` + `desktop_ui.py`), with a layout
preview and live palette updates from `~/.config/sweet-dots/theme.json`.
Do not infer colors from SwayNC CSS. Preserve both languages and the
renderer as the single config writer. `--setup` preserves unsupplied size,
position, widgets and shortcuts.

The saved `niri/workspaces` widget expands to `group/workspaces` with
exactly 2/3/4 custom modules; `workspace-status.py` follows named Niri
workspaces via IPC. Do not hide creation slots with transparent buttons.
`ignored-items` is invalid; filters documented on Waybar master are not
available in 0.15. Niri-specific autostart exclusions and `panel.py` remove
only the current user's duplicate NM/Blueman presentation processes.

Left-clicks on network/Bluetooth/audio open `applets.py` controls, never
the clock panel. Reload with `panel.py --reload`; inspect the persistent
Waybar log after failures. Test standalone GTK under Xvfb and layer-shell
controls in the target user's Niri session. See `docs/PR-REVIEW.md`.
