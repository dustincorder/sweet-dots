# sweet-dots — agent notes

Niri desktop dotfiles. Installs by copying `dotfiles/` over `$HOME`
(`install.sh` only expands `@HOME@`), then renders user choices through
the settings GUI. Read this file first; do not re-explore the tree.

## Map (all paths relative to repo root)

- `install.sh` — copy + backup + `--setup` render. Only does `@HOME@`
  substitution. Never add other placeholders here.
- `dotfiles/.config/niri/config.kdl.tmpl` — entry point, includes
  `common.kdl`, adds polkit agent + hypridle + `Mod+L` lock.
- `dotfiles/.config/niri/common.kdl.tmpl` — env, input (us,ru layouts),
  `@WORKSPACE_*@` slots, blur, autostart (awww, wallpaper apply,
  waybar, swaync, cliphist watcher).
- `dotfiles/.config/niri/bindings.kdl.tmpl` — all keybindings,
  `@WORKSPACE_BINDS@` + `@CUSTOM_BINDS@` slots.
- `dotfiles/.config/niri/visuals*.kdl.tmpl` — layout, focus ring,
  window rules, animations. `visuals.template.kdl.tmpl` uses
  matugen `{{colors...}}`; `visuals.kdl.tmpl` is its last rendered output.
  Same pattern for waybar `style*.css.tmpl`, rofi `niri*.rasi.tmpl`,
  kitty `*template.conf.tmpl`, alacritty `matugen-colors.template.toml.tmpl`.
- `dotfiles/.config/niri/scripts/settings.py.tmpl` — THE renderer + Tk GUI.
  Reads templates from `$HOME/.local/share/sweet-dots/templates/`
  (populated by `install.sh`, note the renamed files), writes deployed
  configs + `$HOME/.config/sweet-dots/settings.json`. See
  `docs/TEMPLATING.md`. Never hand-edit its outputs; change the template
  or `settings.py`, then re-render.
- `dotfiles/.config/niri/scripts/` — `wallpaper.py` (rofi picker + matugen
  + fastfetch portrait + reload), `i18n.py` + `clock.py` + `media-status.py`
  (waybar JSON providers), `capture.sh` (grim freeze → satty annotate),
  `record-toggle.sh` (wf-recorder toggle), `clipboard-menu.sh`
  (cliphist + rofi), `toggle-notifications.sh` (swaync panel),
  `prepare-wallpapers.sh` / `prepare-fastfetch-logo.py` (optional local
  pack builders, need user-supplied sources — never commit outputs).
- `dotfiles/.config/waybar/niri/` — panel config template + styles.
- `dotfiles/.config/niri/swaync/` — notification center + quick settings.
- `dotfiles/.config/matugen/config.toml.tmpl` — wallpaper → palette wiring.
- `dotfiles/.config/{kitty,alacritty,fastfetch,wlogout}/` — terminal colors,
  portrait logo, power menu. `hyprlock.conf.tmpl` / `hypridle.conf.tmpl` —
  lock + 30-min idle lock, no suspend.
- `dotfiles/.zshrc`, `dotfiles/.oh-my-zsh/custom/themes/` — prompt.
- `wallpapers/` — bundled Sweet Pool set (`*.jpg`) + `assets/fastfetch-logos/`
  character sprites for the fastfetch portrait. Generated thumbnails
  (`*-thumb.png`), `current.jpg` symlinks and portraits stay on the machine
  under `$HOME/.local/share/niri/wallpapers/`.

## Rules

1. **No local details in the repo.** No usernames, `$HOME` expansions,
   hostnames, absolute source-media paths, resolutions, tokens, or remote
   usernames. Use `$HOME`, `@HOME@`, `~` placeholders. Generated artifacts
   (thumbnails, portraits, backups, `current.jpg` symlinks) stay outside git.
   Bundled `wallpapers/*.jpg` + `assets/fastfetch-logos/*.png` are the
   explicit exception (user-approved).
2. **Two template layers — don't mix them.** `@VAR@` = expanded by
   `settings.py` at render time. `{{colors...}}` = expanded by matugen at
   wallpaper time. Details: `docs/TEMPLATING.md`.
3. **Generated files are outputs.** `style.css` (not `style.template.css`),
   `visuals.kdl` (not `visuals.template.kdl`), `niri.rasi`, `niri.conf`,
   `matugen-colors.*` — regenerate, don't hand-tweak. Exception: quick
   live check, then port the fix back to the template.
4. **Keep `{ru,en}` pairs together.** Every user-visible string exists in
   `settings.py` `TEXT`, `i18n.py` `TEXT`/`WALLPAPERS`, and rofi/wlogout/
   fastfetch `@UI_@`/`@FF_@` slots. Adding a string in one language only
   is a bug.
5. **Validate before finishing:** `niri validate` (or
   `niri msg action load-config-file`), `python3 -m py_compile` on touched
   scripts, `git diff --check`. Waybar/SwayNC reload commands are in
   `docs/WORKFLOWS.md`.
6. **Update the map when behavior changes.** If you add a template,
   placeholder, widget, script, or workflow, update `AGENTS.md`,
   the relevant `docs/*.md`, and `skills/*.md` in the SAME change.
   Stale docs are treated as a defect.
7. **If launched as root, scope down.** Every user-level command
   (`install.sh`, `settings.py`, `systemctl --user`, `gh`, matugen,
   session checks) runs via `runuser -u <target-user> -- env
   HOME=<target-home> ...` with the target user's `XDG_RUNTIME_DIR`.
   Verify ownership afterwards. Never write root-owned files into a
   user home, never hardcode the actual user/home — placeholders only
   (rule 1).

## Skills

`skills/*/SKILL.md` — trigger-indexed how-tos. Check the index below
before improvising:

- `skills/apply-settings/` — change panel/widgets/shortcuts/language.
- `skills/wallpaper-theming/` — picker, matugen, fastfetch portrait.
- `skills/capture-clipboard/` — screenshots, recording, clipboard history.

## Panel order + shortcuts

Default panel: configured workspaces left; hide only Niri's transient
`N+1` creation slot based on the selected 2/3/4 count. Clock centered
with the recording indicator next to it (click → notification center),
then tray + keyboard layout, network + Bluetooth
+ volume, then power on the right. Network/Bluetooth/volume clicks open
the SwayNC panel; right-clicks open the native editors. Clipboard is keyboard-only
(`Mod+V`, no panel button); settings open on `Mod+Shift+S`.

## First steps for a task

1. Read the matching `docs/*.md` + skill (15 lines each, not the tree).
2. Edit templates / `settings.py`, never deployed outputs.
3. Render + validate (see `docs/WORKFLOWS.md`), check `git diff --check`.
4. Update `AGENTS.md`/`docs`/`skills` if behavior changed.
