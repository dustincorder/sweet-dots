# Skill: wallpaper-theming

Triggers: wallpaper, theme, palette, matugen, fastfetch portrait, accent
color, lock-screen backdrop.

## Chain (`scripts/wallpaper.py`)

pick (rofi, thumbs) → `current.jpg` symlink → `prepare-fastfetch-logo.py`
(PNG portrait) → `matugen image <wp> --mode dark --type scheme-content`
→ `settings.py --refresh-style` → reload niri + `swaync-client
--reload-css` + waybar (`pkill -USR2`).

## Do

- Test with any image dir; keep SOURCES out of git (`wallpapers/*`
  ignored). The optional pack builders (`prepare-wallpapers.sh`)
  take an env-overridable source dir — never hardcode one.
- If the palette collapses (near-black / tinted), adjust the
  `source-color-index` / seed choice in `matugen/config.toml.tmpl`,
  not per-app overrides. Read the matugen error notification first.
- Style edits go to `*.template.*` files; outputs (`style.css`,
  `visuals.kdl`, `niri.rasi`, `*-colors.*`) regenerate.
- Wallpaper labels: add both languages to `i18n.py WALLPAPERS`.
  Portrait matching keys off the wallpaper filename stem — keep the
  naming convention documented in `prepare-fastfetch-logo.py`.
- Keep the wallpaper directory path separate from the imported
  `WALLPAPERS` translation mapping; avoid shadowing it in `wallpaper.py`.

## Don't

- Commit images, portraits, or kudzu `.ansi` artifacts.
- Skip the reload chain — a half-reloaded theme looks like a theming bug.
