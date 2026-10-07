# Architecture

Single-user Niri desktop. One scrolling-column compositor, one top/bottom
dock, one notification center and separate network/Bluetooth/audio overlays. Mouse-first:
new windows take full column width; splitting is always manual.

## Runtime components

| Role | Tool | Config source |
|---|---|---|
| Compositor | Niri | `niri/{config,common,bindings,visuals}.kdl` |
| Dock | Waybar | `waybar/niri/{config.jsonc,style.css}` |
| Calendar + notifications + media | SwayNC | `niri/swaync/{config.json,style.css}` |
| Launcher / menus | Rofi (drun + dmenu) | `rofi/themes/niri.rasi` |
| Wallpaper daemon | awww | driven by `wallpaper.py` |
| Palette from wallpaper | Matugen | `matugen/config.toml` |
| Lock / idle | hyprlock / hypridle | `niri/hyprlock.conf`, `niri/hypridle.conf` |
| Power menu | wlogout | `wlogout/{layout,style.css}` |
| Terminals | Kitty (primary), Alacritty | `kitty/`, `alacritty/` |
| Screenshots | grim (freeze) + GTK selector + swappy (annotate) | `scripts/capture.sh` |
| Recording | wf-recorder (toggle + clickable Waybar status) | `scripts/{record-toggle,recording-status}.sh` |
| Clipboard | wl-clipboard + cliphist + rofi | `scripts/clipboard-menu.sh` |
| Status providers | python3 one-shot JSON | `scripts/{clock,i18n,media-status,keyboard-layout,bluetooth-status}.py/.sh` |
| Controls | GTK3 + gtk-layer-shell | `scripts/{applets,desktop_ui}.py`, `sweet-dots/theme.json` |
| Panel recovery | Python supervisor | `scripts/panel.py` |
| Settings GUI + renderer | python3 + GTK3 | `scripts/settings.py` |
| Shell | Zsh + Oh My Zsh + fastfetch | `.zshrc`, `.oh-my-zsh/...`, `fastfetch/` |

## Data flow

```
install.sh  →  copy dotfiles/ to $HOME (@HOME@ only)
            →  seed $HOME/.local/share/sweet-dots/templates/
            →  settings.py --setup (language, workspaces)
settings.py →  reads templates/ → writes deployed configs
            →  writes $HOME/.config/sweet-dots/settings.json
wallpaper.py → rofi pick → matugen (palette, rollback on error)
            →  awww + current.jpg symlink → transparent fastfetch portrait
            →  settings.py --refresh-style
            →  reload niri / waybar / swaync
```

## Key bindings (defaults; user-customizable via settings GUI)

`Mod` = Super. Launcher `Mod+Space`. Terminal `Ctrl+Alt+T` / `Mod+T`.
Files `Mod+E`. Close `Mod+Q`. Columns: focus `Mod+Left/Right`,
split/rejoin `Alt+Left/Right`, move `Mod+Shift+Left/Right`,
width cycle `Mod+R`, float `Mod+F`, fullscreen `Mod+Shift+F`.
Workspaces `Mod+1..N` / move `Mod+Shift+1..N` (`N` = 2/3/4 chosen at
install). Screenshots `Print` (region) / `Shift+Print` (full),
recording `Ctrl+Print` (audio) / `Ctrl+Shift+Print` (silent),
clipboard `Mod+V`, notifications `Mod+N`, settings `Mod+Shift+S`,
wallpapers `Mod+Shift+W`, hotkey overlay `Mod+Shift+Slash`.

## Panel default order

Left: exactly 2/3/4 configured named workspace buttons in `group/workspaces`;
`workspace-status.py` follows Niri IPC events, so no transient button is allocated. Center:
clock (click → notification center) with the blinking recording indicator
next to it. Right: tray + keyboard layout, then
network + bluetooth + volume, then power, with visual
spacing between those clusters. NetworkManager and Bluetooth applets are
excluded from Niri autostart and stopped by the panel supervisor because
dedicated network/Bluetooth widgets replace them; the keyboard layout is compact text, not a button.
Network/Bluetooth/volume clicks open independent GTK overlays; right-clicks
open native network/Bluetooth editors or mute audio; middle-click opens the mixer. No launcher button on the panel.
