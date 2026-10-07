# Skill: capture-clipboard

Triggers: screenshot, screen recording, clipboard history, annotation,
swappy, wf-recorder, cliphist.

## Screenshot (`scripts/capture.sh region|full`)

Freeze the focused display FIRST (`grim -o`, output from Niri IPC), THEN
show the GTK layer-shell selector from `capture.py`. A left click without
drag selects the full display; drag selects a region; Escape cancels.
Crop the frozen pixbuf with logical-to-pixel scaling, then edit in Swappy
with the toolbar visible. Never re-capture after selection.
`Shift+Print` skips selection. Ctrl+S saves, Ctrl+C copies; after editor
exit an explicitly saved file is copied with `wl-copy --type image/png`.
Closing without saving leaves no output. Temporary frames are cleaned.


## Recording (`scripts/record-toggle.sh [audio|silent] [region|full]`)

Toggle by design: run again to stop. PID + target file in
`$XDG_RUNTIME_DIR/niri-wf-recorder.pid`, log next to it, output in the
XDG videos dir. Silent mode omits `--audio`; audio mode uses the
default sink monitor. The Waybar `custom/recording` indicator appears
only while the PID is alive and stops recording on click. Stop waits for
MP4 finalization and validates it with `ffprobe` before notifying success.

## Clipboard (`scripts/clipboard-menu.sh`, `Mod+V`)

Chain: niri-spawned `wl-paste --watch cliphist store` → `cliphist list`
→ rofi dmenu (themed `niri.rasi`, explicit accept/cancel keys) →
`cliphist decode | wl-copy`. Image rows get cached PNG thumbnails for
Rofi's icon preview; selecting one copies the original bytes back with
the `image/png` MIME type. Empty history notifies instead of opening an
empty menu. Clipboard is keyboard-only on `Mod+V` (no panel button).

## Test inside the session

All three need the compositor session (Wayland socket, same user,
`xdg-user-dir` of that user). Failures outside the session
(`Aborted`, clipboard unavailable, `DISPLAY` complaints) are
environmental — re-test under Niri before changing code.
