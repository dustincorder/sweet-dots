# Desktop repair PR

## Problem and resulting behavior

The default workspace pill allocated an invisible Niri creation button,
leaving space after the last configured workspace. It now renders exactly
2/3/4 named buttons and follows Niri IPC events for active/focused state,
including workspaces on different displays. The saved settings widget ID
remains compatible with existing layouts.

The tray used `ignored-items`, an unsupported option. Even the filters
documented on current Waybar master are unavailable in released 0.15.
Niri-specific autostart overrides and user-scoped presentation-process
cleanup remove NM/Blueman duplicates while preserving the other tray apps
and the underlying NetworkManager/BlueZ services.

Network/Bluetooth/audio clicks previously ran the clock panel command.
They now open separate GTK layer-shell controls. Clock content is limited
to full date/calendar, notifications and media; overlay placement follows
panel height/position. Rounded hover styling applies before and during
hover. GTK settings replace the Tk editor with cards, translated sections,
a panel preview, widget ordering and shortcut editing. Matugen exports a
shared palette JSON consumed by settings and controls, including updates
while windows are open.

Wallpaper changes previously only signalled Waybar. A user-scoped
supervisor now recovers missing/crashed panels and retains the exit status
and diagnostics in the state directory. It stops after three rapid
failures. Partial Matugen failures restore previous outputs without
reloading; CSS scaling replaces files atomically. The reported crash on
the Makoto/Youji snack wallpaper is still awaiting a live reproduction.

Screenshots freeze the focused display, then use click = full display,
drag = region and Escape = cancel. Swappy opens with its annotation tools
visible. Portraits preserve transparency and use bundled sprites, avoiding
the fixed blue canvas and a dependency on an unavailable local game path.

The installer checks GitHub without pulling, reports overwrites/backups,
asks consent and refuses root deployment. Reinstalling preserves panel
size, position and custom shortcuts. Both text and binary dotfiles are
copied safely with only `@HOME@` expansion. README uses the repository URL.

## Local validation

- Regression tests cover rendering in both languages, all workspace counts
  and both panel positions; separate click commands; settings retention;
  invalid shortcuts; partial-theme rollback; click/drag pixel scaling;
  multiple-output workspace state; bounded panel recovery; installer
  decline; real install and reinstall in temporary homes; transparent
  portrait generation with ImageMagick.
- Python template compilation, Bash syntax and `git diff --check`.
- GTK3/Xvfb smoke check: window opens, language switches, widget columns
  render, Apply dispatches. Both Waybar CSS sources parse with GTK3.
  The three applet bodies render with placement/hardware mocked; the audio
  slider dispatches the correct volume command. A real GTK click in the
  screenshot selector saves the complete frozen pixbuf.
- No target-user session is available in this workspace. Niri validation,
  real tray removal and hardware/Wayland interactions must be verified
  on the recipient's machine. Niri/Matugen are absent here.

## Live review before merge

1. Install as the desktop user, then run `panel.py --reload` to restore the
   panel. Check its log and `niri validate`. From root, use the documented
   `runuser` invocation with the target user's HOME and runtime directory.
2. Check workspace counts 2/3/4, clicking each button and empty/active
   styling. Confirm the tray still has application icons but no NM/Blueman
   duplicates. Check local services if they explicitly restart the applets.
3. Click clock, network, Bluetooth and sound separately. Test close,
   Escape, switching overlays, Wi-Fi connection/password, Bluetooth pairing,
   mute/volume/output device and native editors. Check rounded hover states.
4. Switch to the Makoto/Youji snack wallpaper and a differently colored
   wallpaper; check Waybar, clock panel and already-open settings/controls.
   Read the panel log if it fails. Confirm Fastfetch has no blue rectangle.
5. Test screenshot click, drag in both directions, scaled display, Escape,
   full-screen shortcut, annotations, undo, explicit save and clipboard.
6. Reorder widgets and create/edit/delete shortcuts, apply in each language,
   reinstall and verify retained settings/backups.
7. Confirm the live review with the recipient before merging. Revisit
   Fastfetch if any portrait rendering issue remains after removing the
   fixed background.
