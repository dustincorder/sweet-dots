#!/usr/bin/env bash
set -euo pipefail
repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_root="${XDG_STATE_HOME:-$HOME/.local/state}/sweet-dots/backups/$timestamp"
mkdir -p "$backup_root"
while IFS= read -r -d '' source_file; do
  relative="${source_file#"$repo_dir/dotfiles/"}"
  relative="${relative%.tmpl}"
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
printf 'Installed. Existing files were backed up to: %s\n' "$backup_root"
printf 'Add your own images under ~/.local/share/niri/wallpapers before starting Niri.\n'
