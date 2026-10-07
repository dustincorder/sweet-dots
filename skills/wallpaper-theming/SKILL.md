# Skill: wallpaper-theming

Triggers: wallpaper, theme, palette, matugen, fastfetch portrait, accent
color, lock-screen backdrop.

## Chain (`scripts/wallpaper.py`)

pick (rofi, thumbs) → Matugen (palette, restore old outputs on failure)
→ awww + `current.jpg` → transparent PNG fastfetch portrait
→ `settings.py --refresh-style` → niri/SwayNC reload + `panel.py --reload`.

Matugen also renders `niri/theme.json` to `sweet-dots/theme.json` for GTK
settings and applets. Theme outputs must succeed together before reload.
Portrait sprites are installed from the bundled approved assets; an
explicit `SWEET_POOL_CG_DIR` can override them. Never hardcode a background
color or local game directory. Palette outputs/portraits remain local.


## Do

- Test with any image dir; keep SOURCES out of git (generated assets stay local). The optional pack builders (`prepare-wallpapers.sh`)
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

- Commit generated portraits or `.ansi` artifacts; approved bundled sources are allowed.
- Skip the reload chain — a half-reloaded theme looks like a theming bug.
