<div align="center">

# sweet-dots

**A calm, dark Niri desktop inspired by the deep blue aquarium mood of Sweet Pool.**

[![Niri](https://img.shields.io/badge/WM-Niri-263440?style=flat-square)](https://github.com/niri-wm/niri)
[![Wayland](https://img.shields.io/badge/Session-Wayland-253847?style=flat-square)](https://wayland.freedesktop.org/)
[![Arch Linux](https://img.shields.io/badge/Distro-Arch%20based-263440?style=flat-square)](https://archlinux.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-455260?style=flat-square)](LICENSE)

</div>

A personal Niri setup for a mouse-first workflow: one full-width window by default, four workspaces, and optional columns when you want to split the view. The interface uses dark surfaces, quiet cyan/lilac accents, soft corners, and translucent panels.

> The Sweet Pool artwork and other personal wallpapers are not included. The local wallpaper picker uses your own images and Matugen builds a matching dark palette.

## What is included

- **Niri** — scrolling columns, four named workspaces, window rules, animations, idle lock, and keybindings
- **Waybar** — workspaces, tray, date, network, Bluetooth, audio, and resource widgets
- **Rofi + SwayNC** — app picker, quick controls, notifications, and history
- **Kitty + Alacritty** — dark wallpaper-derived colors; Alacritty uses a borderless window frame
- **Matugen + awww** — wallpaper selection, smooth transition, and generated colors for Niri, Waybar, Rofi, SwayNC, and terminals
- **Hyprlock** — lock screen with user avatar and password prompt
- **Zsh + Fastfetch** — a short two-line prompt and a matching system summary
- **Capture tools** — screenshot annotation and screen recording with or without audio

## Install

Designed for Arch Linux and Arch-based distributions. Install the packages first; the script only deploys configuration files and does not install packages or change your display manager.

Core packages: `niri`, `waybar`, `rofi-wayland`, `swaync`, `kitty`, `alacritty`, `matugen`, `awww`, `hyprlock`, `hypridle`, `hyprpolkitagent`, `zsh`, and `fastfetch`.

Desktop helpers: `thunar`, `grim`, `slurp`, `satty`, `wf-recorder`, `wl-clipboard`, `cliphist`, `imagemagick`, `playerctl`, `networkmanager`, `bluez`, `pipewire`, `pipewire-pulse`, `wireplumber`, and `brightnessctl`. Oh My Zsh is expected at `~/.oh-my-zsh`.

```sh
git clone https://github.com/dustincorder/sweet-dots.git
cd sweet-dots
./install.sh
```

The installer backs up every file it replaces under `~/.local/state/sweet-dots/backups/`. It expands the `@HOME@` paths for the current account and creates the local wallpaper folder. It does not include any wallpaper files.

Put images in `~/.local/share/niri/wallpapers/`. Supported formats are PNG, JPEG, WebP, and AVIF. Open the wallpaper picker from the top bar; Matugen updates the accent colors.

Choose the **Niri** session in your display manager to use the full desktop. GNOME remains a separate session.

## Keybindings

`Mod` means Super/Windows. The nested preview launched from GNOME may use Alt as its Niri modifier.

| Shortcut | Action |
|---|---|
| `Mod+D` or `Mod+Space` | Open the app picker |
| `Ctrl+Alt+T` | Open Kitty |
| `Mod+Q` | Close the focused window |
| `Mod+←` / `Mod+→` | Focus the adjacent column |
| `Mod+Shift+←` / `Mod+Shift+→` | Move a column |
| `Mod+R` | Cycle the column width |
| `Mod+F` | Toggle floating mode |
| `Mod+1` … `Mod+4` | Switch workspaces |
| `Mod+Shift+1` … `Mod+Shift+4` | Move the window to a workspace |
| `Print` | Select and annotate a screenshot |
| `Shift+Print` | Annotate a full-screen screenshot |
| `Ctrl+Print` | Record a selected area with audio; press again to stop |
| `Ctrl+Shift+Print` | Record a selected area without audio; press again to stop |
| `Mod+V` | Open clipboard history |
| `Mod+Shift+/` | Open Niri’s built-in shortcut guide |

New windows fill the available width by default. Use `Mod+R` or the bracket bindings to make columns side by side when needed.

## Theme notes

- Firefox uses its **Dark** appearance; set it in Firefox under **Settings → General → Appearance** if the current browser profile keeps its own light theme.
- Personal wallpapers and avatars are machine-local and are not tracked.
- The login manager theme is not part of this repository.

## Suggested GitHub topics

`niri` · `niri-dots` · `wayland` · `dotfiles` · `arch-linux` · `waybar` · `matugen` · `rofi` · `swaync` · `sweet-pool`

## License

MIT. See [LICENSE](LICENSE).
