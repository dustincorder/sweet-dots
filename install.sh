#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/sweet-dots/backups/$timestamp"
assume_yes=false
check_updates=true
for argument in "$@"; do
  case "$argument" in
    --yes) assume_yes=true ;;
    --skip-update-check) check_updates=false ;;
    *) printf 'Usage: ./install.sh [--yes] [--skip-update-check]\n' >&2; exit 2 ;;
  esac
done
if [[ "$(id -u)" == 0 ]]; then
  printf 'Run as the desktop user: runuser -u <target-user> -- env HOME=<target-home> ./install.sh\n' >&2
  exit 1
fi
if $check_updates && command -v git >/dev/null && command -v timeout >/dev/null; then
  printf 'Checking GitHub / Проверка GitHub…\n'
  upstream="$(timeout 8 git ls-remote https://github.com/dustincorder/sweet-dots.git refs/heads/main 2>/dev/null | awk '{print $1}')" || upstream=''
  current="$(git -C "$repo_dir" rev-parse HEAD 2>/dev/null)" || current=''
  if [[ -z "$upstream" ]]; then
    printf 'Update check unavailable (offline?) / Проверка обновлений недоступна.\n'
  elif [[ "$current" != "$upstream" ]]; then
    if git -C "$repo_dir" merge-base --is-ancestor "$upstream" HEAD 2>/dev/null; then
      printf 'Local checkout includes changes beyond GitHub main / Локальная ветка содержит дополнительные изменения.\n'
    else
      printf 'GitHub main differs from this checkout; review updates before installing.\nGitHub main отличается от этой копии; проверь обновления перед установкой.\n'
    fi
  else
    printf 'GitHub main is current / Копия соответствует GitHub main.\n'
  fi
fi
printf 'This copies dotfiles into your home and replaces matching configs, scripts and shell settings.\nСкрипт заменит совпадающие конфиги, скрипты и настройки оболочки в домашней папке.\n'
printf 'Backups / Резервные копии: %s\n' "$backup_root"
printf 'Saved panel layout and shortcuts are preserved / Раскладка панели и свои сочетания сохраняются.\n'
if ! $assume_yes; then
  printf 'Continue / Продолжить? [y/N]: '
  read -r consent
  case "$consent" in y|Y|yes|YES|да|Да) ;; *) exit 0 ;; esac
fi
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
  python3 - "$source_file" "$temporary" <<'PY'
import os
from pathlib import Path
import sys
Path(sys.argv[2]).write_bytes(Path(sys.argv[1]).read_bytes().replace(b'@HOME@', os.fsencode(os.environ['HOME'])))
PY
  mv -- "$temporary" "$target"
  case "$relative" in .config/niri/scripts/*) chmod 755 "$target" ;; esac
done < <(find "$repo_dir/dotfiles" -type f -print0)
mkdir -p "$HOME/.local/share/niri/wallpapers"
for asset_dir in wallpapers assets/fastfetch-logos; do
  case "$asset_dir" in
    wallpapers) destination="$HOME/.local/share/niri/wallpapers" ;;
    *) destination="$HOME/.local/share/sweet-dots/fastfetch-logos" ;;
  esac
  mkdir -p "$destination"
  while IFS= read -r -d '' asset; do
    target="$destination/$(basename "$asset")"
    if [[ -e "$target" ]]; then
      relative="${target#"$HOME/"}"
      mkdir -p "$backup_root/$(dirname "$relative")"
      cp -a -- "$target" "$backup_root/$relative"
    fi
    cp -- "$asset" "$target"
  done < <(find "$repo_dir/$asset_dir" -maxdepth 1 -type f \( -name '*.jpg' -o -name '*.png' \) -print0)
done
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
if [[ -n "${NIRI_SOCKET:-}" ]]; then
  python3 "$HOME/.config/niri/scripts/wallpaper.py" --apply-current
fi
printf 'Installed. Existing files were backed up to: %s\n' "$backup_root"
printf 'Bundled wallpapers installed; add more under ~/.local/share/niri/wallpapers.\n'
