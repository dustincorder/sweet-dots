Bundled Sweet Pool wallpapers + fastfetch character logos.

- `wallpapers/*.jpg` — shipped with the repo (user-approved). The installer
  does NOT copy them; put your own images under
  `~/.local/share/niri/wallpapers/` (see `prepare-wallpapers.sh`).
- `assets/fastfetch-logos/*.png` — reference character sprites matching what
  `prepare-fastfetch-logo.py` pulls from the machine CG pack
  (`$SWEET_POOL_CG_DIR`, wallpaper → character: `makoto` → 睦,
  `zenya` → 善弥, `tetsuo` → 哲雄, `yoji`/`aquarium` → 蓉司) to render
  `fastfetch-portrait.png`. If the CG pack is missing, copy the needed
  sprite next to the script sources and point `SWEET_POOL_CG_DIR` at it.
