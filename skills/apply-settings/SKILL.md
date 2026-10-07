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
