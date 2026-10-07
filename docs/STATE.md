# State — desktop repair PR

Changes are prepared for a requested pull request. Live verification on
the recipient's desktop remains pending before merge.

Implementation, diagnosis and the review sequence are documented in
[PR-REVIEW.md](PR-REVIEW.md). The main changes are workspace buttons,
duplicate tray applet suppression, separate GTK controls, Matugen-themed
settings, supervised panel recovery, transactional theme failure handling,
frozen screenshot selection with Swappy, transparent Fastfetch portraits
and installer consent/update checks.

Automated renderer/installer/regression checks and GTK/Xvfb smoke checks
can run without touching the desktop user's home. Live Niri validation,
Wayland overlays, hardware actions and the snack-wallpaper crash require
the recipient's session. Preserve the Waybar log when investigating.
Fastfetch should be reviewed again with the recipient after the fixed
blue background is removed.
