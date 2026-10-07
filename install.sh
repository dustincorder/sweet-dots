#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/sweet-dots/backups/$timestamp"
printf 'Language / Язык [1 Русский, 2 English] (default 1): '
read -r language_choice
case "$language_choice" in 2|en|EN) language="en" ;; *) language="ru" ;; esac
printf 'Number of workspaces [2/3/4] (default 2): '
read -r workspace_choice
case "$workspace_choice" in 3|4) workspaces="$workspace_choice" ;; *) workspaces=2 ;; esac
mkdir -p "$backup_root"
while IFS= read -r -d '' source_file; do
  relative="${source_file#"$repo_dir/dotfiles/"}"
  relative="${relative%.tmpl}"
  case "$relative" in
    .config/niri/common.kdl|.config/niri/bindings.kdl|.config/niri/hyprlock.conf|\
    .config/waybar/niri/config.jsonc|.config/niri/swaync/config.json|\
    .config/wlogout/layout|.config/fastfetch/config.jsonc)
      continue
      ;;
  esac
  target="$HOME/$relative"
  mkdir -p "$(dirname "$target")"
  if [[ -e "$target" || -L "$target" ]]; then
    mkdir -p "$backup_root/$(dirname "$relative")"
    cp -a -- "$target" "$backup_root/$relative"
  fi
  temporary="$target.sweet-dots-tmp"
  sed "s|@HOME@|$HOME|g" "$source_file" > "$temporary"
  mv -- "$temporary" "$target"
  case "$relative" in .config/niri/scripts/*) chmod 755 "$target" ;; esac
done < <(find "$repo_dir/dotfiles" -type f -print0)
mkdir -p "$HOME/.local/share/niri/wallpapers"
template_root="$HOME/.local/share/sweet-dots/templates"
mkdir -p "$template_root"
cp "$repo_dir/dotfiles/.config/niri/common.kdl.tmpl" "$template_root/common.kdl.tmpl"
cp "$repo_dir/dotfiles/.config/niri/bindings.kdl.tmpl" "$template_root/bindings.kdl.tmpl"
cp "$repo_dir/dotfiles/.config/waybar/niri/config.jsonc.tmpl" "$template_root/waybar-config.jsonc.tmpl"
cp "$repo_dir/dotfiles/.config/niri/swaync/config.json.tmpl" "$template_root/swaync-config.json.tmpl"
cp "$repo_dir/dotfiles/.config/wlogout/layout.tmpl" "$template_root/wlogout-layout.tmpl"
cp "$repo_dir/dotfiles/.config/rofi/themes/niri.rasi.tmpl" "$template_root/rofi-theme.rasi.tmpl"
cp "$repo_dir/dotfiles/.config/niri/hyprlock.conf.tmpl" "$template_root/hyprlock.conf.tmpl"
cp "$repo_dir/dotfiles/.config/fastfetch/config.jsonc" "$template_root/fastfetch-config.jsonc.tmpl"
printf 'Language / Язык: %s · workspaces / рабочих мест: %s\n' "$language" "$workspaces"
python3 "$HOME/.config/niri/scripts/settings.py" --setup --language "$language" --workspaces "$workspaces"
rm -f "$HOME/.local/share/sweet-dots/fastfetch-portrait.ansi"
printf 'Installed. Existing files were backed up to: %s\n' "$backup_root"
printf 'Add your own images under ~/.local/share/niri/wallpapers before starting Niri.\n'
