# Architecture

Single-user Niri desktop. One scrolling-column compositor, one top/bottom
dock, one notification center that doubles as quick settings. Mouse-first:
new windows take full column width; splitting is always manual.

## Runtime components

| Role | Tool | Config source |
|---|---|---|
| Compositor | Niri | `niri/{config,common,bindings,visuals}.kdl` |
| Dock | Waybar | `waybar/niri/{config.jsonc,style.css}` |
| Notifications + quick settings | SwayNC | `niri/swaync/{config.json,style.css}` |
| Launcher / menus | Rofi (drun + dmenu) | `rofi/themes/niri.rasi` |
| Wallpaper daemon | awww | driven by `wallpaper.py` |
| Palette from wallpaper | Matugen | `matugen/config.toml` |
| Lock / idle | hyprlock / hypridle | `niri/hyprlock.conf`, `niri/hypridle.conf` |
| Power menu | wlogout | `wlogout/{layout,style.css}` |
| Terminals | Kitty (primary), Alacritty | `kitty/`, `alacritty/` |
| Screenshots | grim (freeze) + satty (crop/annotate) | `scripts/capture.sh` |
| Recording | wf-recorder (toggle + clickable Waybar status) | `scripts/{record-toggle,recording-status}.sh` |
| Clipboard | wl-clipboard + cliphist + rofi | `scripts/clipboard-menu.sh` |
| Status providers | python3 one-shot JSON | `scripts/{clock,i18n,media-status,keyboard-layout,bluetooth-status}.py/.sh` |
| Settings GUI + renderer | python3 + Tk | `scripts/settings.py` |
| Shell | Zsh + Oh My Zsh + fastfetch | `.zshrc`, `.oh-my-zsh/...`, `fastfetch/` |

## Data flow

```
install.sh  →  copy dotfiles/ to $HOME (@HOME@ only)
            →  seed $HOME/.local/share/sweet-dots/templates/
            →  settings.py --setup (language, workspaces)
settings.py →  reads templates/ → writes deployed configs
            →  writes $HOME/.config/sweet-dots/settings.json
wallpaper.py → rofi pick → current.jpg symlink → matugen (palette)
            →  fastfetch portrait → settings.py --refresh-style
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

Left: configured workspaces; the transient `N+1` creation slot is hidden
dynamically from the selected count (2/3/4). Center:
clock (click → notification center). Right: tray + keyboard layout, then
network + bluetooth + volume, then recording status + power, with visual
spacing between those clusters. NetworkManager and Bluetooth applets are
hidden from the tray because dedicated network/Bluetooth widgets replace
them; the keyboard layout is compact text, not a button.
Network/bluetooth/volume clicks open the SwayNC panel; right-clicks open
the native editors. No launcher button on the panel.
