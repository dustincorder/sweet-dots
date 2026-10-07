<div align="center">

# sweet-dots

### A quiet, dark Niri desktop with a deep-water palette

One large window by default. Choose two, three, or four workspaces. Split into columns when you choose.

[![Niri](https://img.shields.io/badge/WM-Niri-172c3b?style=for-the-badge)](https://github.com/niri-wm/niri)
[![Wayland](https://img.shields.io/badge/Session-Wayland-1b3544?style=for-the-badge)](https://wayland.freedesktop.org/)
[![Arch based](https://img.shields.io/badge/Linux-Arch%20based-253442?style=for-the-badge)](https://archlinux.org/)
[![MIT](https://img.shields.io/badge/License-MIT-354554?style=for-the-badge)](LICENSE)

</div>

## At a glance

| | | |
|---|---|---|
| **Compositor** | Niri | Scrolling columns; workspaces are selected during installation |
| **Panel** | Waybar | Workspaces left, clock centered, configurable widgets right |
| **Files** | Nautilus | GNOME Files, opened by `Mod+E` |
| **Launcher** | Rofi | Search installed applications with `Win+Space`; no launcher button on the panel |
| **Notifications** | SwayNC | Compact notifications, history, calendar and media; separate network/Bluetooth/audio overlays |
| **Theme** | Matugen + awww | Dark colors derived from the selected wallpaper |
| **Terminal** | Kitty + Alacritty | JetBrains Mono Nerd Font and generated terminal colors |
| **Shell** | Zsh + Fastfetch | Single-line prompt and a full-resolution portrait that follows the selected wallpaper |
| **Lock screen** | Hyprlock | Aquarium backdrop, separate AccountsService avatar, username, and password prompt |
| **Power menu** | Wlogout | Lock, logout, suspend, reboot, and power off |
| **Capture** | Grim + Swappy + wf-recorder | Annotated screenshots and recordings with or without audio |

The setup is designed for mouse-first use. New windows take the available width; they do not split the screen automatically. Use `Alt+←/→` when you want to split a window into another column.

## Install

For Arch Linux and Arch-based distributions. Install the packages first; the script backs up and deploys dotfiles. It does not change the display manager or install packages.

```sh
git clone https://github.com/dustincorder/sweet-dots
cd sweet-dots
./install.sh
```

The installer checks GitHub main without pulling, explains which files it replaces, and asks consent before copying. `--yes` skips consent; `--skip-update-check` skips the offline update check. It refuses to deploy as root. It then asks for the interface language (Russian or English) and workspace count (two, three, or four). It backs up replaced files under `~/.local/state/sweet-dots/backups/` and expands the `@HOME@` paths for your account.

Open **Sweet Dots Settings** from the application launcher, press `Mod+Shift+S`, or run `python3 ~/.config/niri/scripts/settings.py`. The GTK settings window uses the bar’s Matugen palette, rounded cards and a layout preview. It lets you change panel position and height, widget size, clock date, language, and workspace count. Its dock tab lets you add, remove, reorder, and reposition built-in widgets. The shortcuts tab lets you add, edit, and remove custom keybindings and panel buttons. Changes are saved under `~/.config/sweet-dots/settings.json`.

### Packages

Core: `niri`, `waybar`, `rofi-wayland`, `swaync`, `wlogout`, `kitty`, `alacritty`, `matugen`, `awww`, `hyprlock`, `hypridle`, `hyprpolkitagent`, `zsh`, `fastfetch`, `python-gobject`, `python-cairo`, `gtk3`, `gtk-layer-shell` (settings, controls and screenshot selection).

Desktop tools: `nautilus`, `grim`, `slurp`, `swappy`, `wf-recorder`, `wl-clipboard`, `cliphist`, `imagemagick`, `playerctl`, `networkmanager`, `bluez`, `pipewire`, `pipewire-pulse`, `libpulse`, `wireplumber`, `brightnessctl`, `network-manager-applet`, `blueman`, `pavucontrol`. The Zsh config expects Oh My Zsh at `~/.oh-my-zsh`.

Choose **Niri** in the login screen. GNOME remains available as a separate session.

## Wallpapers

Put your own images in `~/.local/share/niri/wallpapers/`. The picker accepts PNG, JPEG, WebP, and AVIF. Selecting an image updates the dark palette used by Niri, Waybar, Rofi, SwayNC, and the terminals.

To add a personal Sweet Pool set from an existing local game-data folder, run:

```sh
SWEET_POOL_CG_DIR=/path/to/local/cg ~/.config/niri/scripts/prepare-wallpapers.sh
```

It makes seven static dark wallpapers and a Fastfetch portrait from scenes with Youji, Makoto, Tetsuo, and Zenya. The set includes one mild bruised-face scene; it avoids sex scenes and body horror. If the game files are stored elsewhere, set `SWEET_POOL_CG_DIR` to the folder that contains `ev/` and `st/` before running it. The approved wallpaper set and transparent character sprites are bundled and installed automatically. Additional generated images stay local.

## Keybindings

`Mod` is Super/Windows. In a nested preview launched from GNOME, Niri may use Alt as its modifier.

| Shortcut | Action |
|---|---|
| `Mod+Space` | Open the app picker |
| `Mod+Shift+S` | Open Sweet Dots Settings |
| `Ctrl+Alt+T` | Open Kitty |
| `Mod+Q` | Close the focused window |
| `Mod+←/→` | Focus the adjacent column |
| `Alt+←/→` | Split or rejoin the focused window with the adjacent column |
| `Mod+Shift+←/→` | Move a column |
| `Mod+R` | Cycle the column width |
| `Mod+F` | Toggle floating mode |
| `Mod+1` … `Mod+N` | Switch workspaces (`N` is chosen during installation) |
| `Mod+Shift+1` … `Mod+Shift+N` | Move the window to a workspace |
| `Print` | Freeze the focused display; drag for region or click for full screen, then edit in Swappy |
| `Shift+Print` | Annotate a full-screen screenshot |
| `Ctrl+Print` | Record a selected area with audio; press again to stop |
| `Ctrl+Shift+Print` | Record a selected area without audio; press again to stop |
| `Mod+V` | Open clipboard history; images are supported |
| `Mod+Shift+/` | Open Niri’s built-in shortcut guide |

The default panel order: named workspace buttons (exactly the configured count), clock, tray, keyboard layout, network, Bluetooth, volume, and power. Click the clock for full date, calendar, notifications and media. Network, Bluetooth and volume each open their own controls; the two duplicate system applets are excluded from the Niri tray. Their background services remain running. Overlays and settings follow the same Matugen palette as the bar. Clipboard history opens with `Mod+V` only. The settings window can move and reorder widgets, change the panel height and widget size, or add optional CPU, memory, media, wallpaper, and notification widgets.

Click the power symbol for lock, logout, suspend, reboot, and shutdown. App shortcuts and panel buttons can be created together in the settings window; keybindings are validated before they are written to Niri.

Kitty opens a URL under the pointer with a middle click. In Alacritty, click a URL with the left mouse button; middle click remains paste-from-selection.

## Personal files

Wallpaper files, avatars, and generated local color files are machine-specific. Keep them outside the repository; the checked-in configs point to paths under your home directory. Set the lock-screen avatar at `~/.local/share/niri/avatar.png`.

## License

The configuration and installer are MIT licensed. See [LICENSE](LICENSE).

## Panel recovery and testing

Run `python3 ~/.config/niri/scripts/panel.py --reload` inside Niri to restore
a missing panel. Diagnostics are in `~/.local/state/sweet-dots/waybar.log`.
Matugen failures roll back the previous theme before any reload.

Repository checks: `python3 -m unittest discover -s tests -v`, Python compile,
`git diff --check`, and `niri validate` on the target machine. See
[PR review steps](docs/PR-REVIEW.md) for the live verification sequence.
