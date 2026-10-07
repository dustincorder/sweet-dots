# Templating

Two layers. They compose but never substitute each other.

## Layer 1 — `settings.py` (`@VAR@`)

Expanded when `settings.py apply()` / `--setup` runs. Source templates
live in the repo under `dotfiles/.../*.tmpl`; at runtime `settings.py`
reads them from `$HOME/.local/share/sweet-dots/templates/` (seeded by
`install.sh` — note the renamed files, e.g. `waybar-config.jsonc.tmpl`).

`TARGETS` map (template → deployed file):

```
common.kdl.tmpl            → ~/.config/niri/common.kdl
bindings.kdl.tmpl          → ~/.config/niri/bindings.kdl
waybar-config.jsonc.tmpl   → ~/.config/waybar/niri/config.jsonc
swaync-config.json.tmpl    → ~/.config/niri/swaync/config.json
hyprlock.conf.tmpl         → ~/.config/niri/hyprlock.conf
fastfetch-config.jsonc.tmpl→ ~/.config/fastfetch/config.jsonc
wlogout-layout.tmpl        → ~/.config/wlogout/layout
```

Placeholder groups:

- `@HOME@` — the only one `install.sh` expands (byte-preserving substitution). Everything
  else is expanded by `settings.py`.
- `@WORKSPACE_DECLARATIONS@`, `@WORKSPACE_BINDS@`, `@WORKSPACE_WIDGET_DEFS@` —
  derived from the `workspaces` setting (2/3/4). The saved widget ID
  `niri/workspaces` expands to `group/workspaces` with exactly that many
  `custom/workspace-N` definitions. Each listens to Niri IPC, without
  depending on workspace filters unavailable in released Waybar.
- `@CUSTOM_BINDS@`, `@USER_WIDGET_DEFS@` — derived from custom
  `shortcuts[]` (`{label, key, command, icon}`). Key format:
  `[A-Za-z0-9_+-]+`, must be unique (case-insensitive); each shortcut
  also becomes a `custom/user-shortcut-N` waybar module.
- `@MODULES_LEFT@`, `@MODULES_CENTER@`, `@MODULES_RIGHT@` — JSON arrays
  from `groups`. Widgets must come from the `WIDGETS` registry;
  duplicates across groups are rejected.
- `@PANEL_POSITION@` (`top`/`bottom`), `@PANEL_HEIGHT@` (32/40/48),
  `@PANEL_MARGIN_TOP@`/`@PANEL_MARGIN_BOTTOM@`,
  `@OVERLAY_MARGIN_TOP@`/`@OVERLAY_MARGIN_BOTTOM@` (panel height + 11px),
  `@PANEL_FONT_SIZE@`/`@PANEL_BUTTON_SIZE@` (from `widget_size`).
- `@UI_*@`, `@POWER_TOOLTIP@`, `@FF_*@` — localized strings
  (`ru`/`en` from the `language` setting).

`render()` raises on any leftover `@...@`. `settings.json` schema:
`{language, workspaces, clock_date, panel_size, widget_size, position,
groups{left,center,right}, shortcuts[]}`.

## Layer 2 — matugen (`{{colors...}}`)

Expanded when `matugen image <wallpaper>` runs (triggered by
`wallpaper.py`). Files: `niri/theme.json.tmpl` (GTK palette JSON), `visuals.template.kdl.tmpl`,
`style.template.css.tmpl`, `niri.template.rasi.tmpl`,
`kitty/niri.template.conf` + `matugen-colors.template.conf`,
`alacritty/matugen-colors.template.toml`. Matugen config:
`dotfiles/.config/matugen/config.toml.tmpl`
(dark `scheme-content`, wallpaper fade transition).

Outputs (`visuals.kdl`, `style.css`, `niri.rasi`, `niri.conf`,
`matugen-colors.*`) are GENERATED — edit the `.template.*` source and
re-run matugen, never the output. Note: `wallpaper.py` also calls
`settings.py --refresh-style` (widget scale) and reloads
niri + swaync css + waybar after matugen.

## Rules for changes

- New user-visible string → add `ru`+`en` to `settings.py TEXT`,
  `i18n.py` if scripts need it, and the `@UI_@`/`@FF_@` slot in every
  affected template.
- New widget → register in `WIDGETS` (+ both languages), add the waybar
  module block in `config.jsonc.tmpl`, style it in both style templates.
- New placeholder → handle it in `render()` values, extend the
  leftover-check regex, document here.
- `install.sh` stays `@HOME@`-only. Anything richer belongs in
  `settings.py`.

The installer deploys the palette source as `~/.config/niri/theme.json`;
Matugen writes `~/.config/sweet-dots/theme.json`. GTK controls read this JSON
rather than parsing another application's CSS, and refresh it while open.
`wallpaper.py` restores every previous palette output on Matugen failure;
only a successful theme triggers wallpaper/portrait changes and reloads.
CSS scale adjustment uses atomic replacement, never an in-place truncate.
