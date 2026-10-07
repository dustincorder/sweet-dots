# State — pending work (generic; machine specifics live outside the repo)

## Uncommitted functional diff (review, then commit as one or split)

- i18n + installer prompts: language (ru/en) and workspace count (2/3/4)
  selection in `install.sh`; `@UI_@`/`@FF_@` localization across waybar,
  swaync, rofi, wlogout, hyprlock, fastfetch; `i18n.py` string table.
- Panel rework in `waybar/.../config.jsonc.tmpl`: `custom/clock-center`
  provider, `custom/power` (wlogout) replacing the layout widget slot,
  click-through to the SwayNC panel, revised module set.
- Capture flow: `capture.sh` freezes the frame with grim FIRST, then
  annotates in satty (preserves short-lived notifications); `capture-tools.sh`
  rofi menu rewritten around it; `record-toggle.sh` saves under the
  XDG videos directory with localized notifications.
- Wallpaper flow: `wallpaper.py` thumbnail + label handling,
  matugen dark `scheme-content` + style refresh + reload chain;
  `prepare-fastfetch-logo.py` renders a full-resolution PNG portrait
  matched to the wallpaper (replaces the old ANSI path).
- Style pass on both waybar style templates + both rofi themes
  (graphite fills, accent kept to text/icons).

## Untracked (review, then `git add`)

- `scripts/settings.py.tmpl` — settings GUI + renderer (TARGETS,
  validation, backups, reloads). Largest new piece; needs a careful
  read of `render()`/`apply()`/`gui()` before commit.
- `scripts/{i18n,clock,media-status}.py.tmpl` — waybar JSON providers.
- `dotfiles/.local/share/applications/sweet-dots-settings.desktop.tmpl` —
  launcher entry for the GUI.
- `scripts/__pycache__/` — build artifact, must NOT be committed
  (gitignore covers it after this change).

## Known blockers (environmental, not code)

1. Last install attempt ran with the wrong `$HOME`, so the user session
   still shows the pre-diff panel. Re-run `./install.sh` as the target
   user with the correct `$HOME`, then verify `settings.json` + deployed
   waybar config.
2. Last push attempt failed on SSH host-key verification. Fix transport
   (host keys / remote URL) and push; do not bake credentials into the repo.
3. Fastfetch portrait + wallpaper pack are generated on the machine from
   user-supplied sources — confirm they regenerate cleanly after the
   re-install; outputs stay untracked.

## Definition of done for the pending change

`install.sh` from a clean checkout → GUI opens → language/workspaces/panel
apply → wallpaper switch re-themes all apps → `niri validate` +
`py_compile` + `git diff --check` clean → commit → push succeeds.
