"""Regression checks run in temporary homes, without a compositor session."""
import argparse
import copy
import importlib.machinery
import importlib.util
import json
import os
import shutil
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / 'dotfiles/.config/niri/scripts'


def load(name):
    loader = importlib.machinery.SourceFileLoader(name, str(SCRIPTS / f'{name}.py.tmpl'))
    module = importlib.util.module_from_spec(importlib.util.spec_from_loader(name, loader))
    sys.modules[name] = module
    loader.exec_module(module)
    return module


class DesktopTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.home = Path(self.directory.name)
        self.environment = patch.dict(os.environ, {'HOME': str(self.home), 'NIRI_SOCKET': '', 'XDG_STATE_HOME': str(self.home / '.local/state'), 'XDG_RUNTIME_DIR': str(self.home)})
        self.environment.start()
        self.addCleanup(self.environment.stop)
        load('i18n')
        self.settings = load('settings')
        self.settings.TEMPLATES.mkdir(parents=True)
        sources = {
            'common.kdl.tmpl': '.config/niri/common.kdl.tmpl',
            'bindings.kdl.tmpl': '.config/niri/bindings.kdl.tmpl',
            'waybar-config.jsonc.tmpl': '.config/waybar/niri/config.jsonc.tmpl',
            'swaync-config.json.tmpl': '.config/niri/swaync/config.json.tmpl',
            'hyprlock.conf.tmpl': '.config/niri/hyprlock.conf.tmpl',
            'fastfetch-config.jsonc.tmpl': '.config/fastfetch/config.jsonc',
            'wlogout-layout.tmpl': '.config/wlogout/layout.tmpl',
        }
        for target, source in sources.items():
            (self.settings.TEMPLATES / target).write_text((ROOT / 'dotfiles' / source).read_text())

    def test_render_counts_languages_positions_and_clock_content(self):
        for lang in ('ru', 'en'):
            for count in (2, 3, 4):
                for position in ('top', 'bottom'):
                    prefs = self.settings.read_settings()
                    prefs.update(language=lang, workspaces=count, position=position)
                    for name in self.settings.TARGETS:
                        rendered = self.settings.render(name, prefs)
                        self.assertNotRegex(rendered, r'@(HOME|WORKSPACE_[A-Z_]+|MODULES_[A-Z_]+|PANEL_[A-Z_]+|OVERLAY_[A-Z_]+|UI_[A-Z_]+|FF_[A-Z_]+)@')
                    bar = json.loads(self.settings.render('waybar-config.jsonc.tmpl', prefs))
                    self.assertEqual(len(bar['group/workspaces']['modules']), count)
                    self.assertNotIn('niri/workspaces', bar['modules-left'])
                    self.assertNotIn(f'custom/workspace-{count + 1}', bar)
                    for module, kind in (('network', 'network'), ('custom/bluetooth', 'bluetooth'), ('pulseaudio', 'audio')):
                        self.assertTrue(bar[module]['on-click'].endswith('applets.py ' + kind))
                    center = json.loads(self.settings.render('swaync-config.json.tmpl', prefs))
                    self.assertEqual(set(center['widgets']), {'calendar', 'title', 'mpris', 'notifications'})
                    self.assertEqual(center[f'control-center-margin-{position}'], 51)

    def test_reapply_preserves_panel_and_shortcuts(self):
        prefs = self.settings.read_settings()
        prefs.update(panel_size='large', widget_size='small', position='bottom', clock_date=True)
        prefs['shortcuts'] = [{'key': 'Mod+Shift+X', 'label': 'Test', 'command': 'true', 'icon': ''}]
        prefs['groups']['right'].append('custom/user-shortcut-1')
        self.settings.apply(prefs)
        args = argparse.Namespace(language='en', workspaces=3, panel_size=None, widget_size=None, position=None)
        self.settings.cli_setup(args)
        actual = self.settings.read_settings()
        for key in ('panel_size', 'widget_size', 'position', 'clock_date', 'groups', 'shortcuts'):
            self.assertEqual(actual[key], prefs[key])
        self.assertEqual(actual['language'], 'en')

    def test_invalid_shortcut_does_not_replace_settings(self):
        prefs = self.settings.read_settings()
        self.settings.apply(prefs)
        before = self.settings.SETTINGS.read_bytes()
        prefs['shortcuts'] = [{'key': 'Mod+X', 'label': 'Test', 'command': 'true'},
                              {'key': 'mod+x', 'label': 'Other', 'command': 'false'}]
        with self.assertRaises(ValueError):
            self.settings.apply(prefs)
        self.assertEqual(self.settings.SETTINGS.read_bytes(), before)

    def test_install_decline_writes_nothing(self):
        result = subprocess.run(['bash', str(ROOT / 'install.sh'), '--skip-update-check'],
                                input='n\n', text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((self.home / '.config/niri/config.kdl').exists())
        self.assertFalse((self.home / '.local/state/sweet-dots/backups').exists())

    def test_real_install_and_reinstall_in_isolated_home(self):
        result = subprocess.run(['bash', str(ROOT / 'install.sh'), '--yes', '--skip-update-check'],
                                input='en\n3\n', text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        bar = json.loads((self.home / '.config/waybar/niri/config.jsonc').read_text())
        self.assertEqual(len(bar['group/workspaces']['modules']), 3)
        self.assertTrue((self.home / '.local/share/sweet-dots/fastfetch-logos').is_dir())
        self.assertIn('NotShowIn=niri;Niri;', (self.home / '.config/autostart/blueman.desktop').read_text())
        prefs = self.settings.read_settings()
        prefs.update(panel_size='large', widget_size='small', position='bottom')
        self.settings.apply(prefs)
        result = subprocess.run(['bash', str(ROOT / 'install.sh'), '--yes', '--skip-update-check'],
                                input='en\n3\n', text=True, capture_output=True, check=False)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.settings.read_settings()['position'], 'bottom')
        self.assertTrue(list((self.home / '.local/state/sweet-dots/backups').glob('*/.zshrc')))

    def test_partial_matugen_failure_restores_every_output(self):
        wallpaper = load('wallpaper')
        wallpaper.WALLPAPER_DIR.mkdir(parents=True)
        image = wallpaper.WALLPAPER_DIR / 'new.jpg'
        image.write_bytes(b'new wallpaper')
        old = wallpaper.WALLPAPER_DIR / 'old.jpg'
        old.write_bytes(b'old wallpaper')
        wallpaper.CURRENT.symlink_to(old)
        existing, created = self.home / 'old.css', self.home / 'new.css'
        existing.write_text('old theme')
        wallpaper.THEME.parent.mkdir(parents=True)
        wallpaper.THEME.write_text(f'[templates.one]\noutput_path = "{existing}"\n[templates.two]\noutput_path = "{created}"\n')
        def run(argv, **kwargs):
            if argv[0] == 'matugen':
                existing.write_text('broken theme')
                created.write_text('partial theme')
                return subprocess.CompletedProcess(argv, 1, '', 'template failure')
            self.assertEqual(argv[0], 'notify-send')
            return subprocess.CompletedProcess(argv, 0)
        with patch.object(wallpaper.subprocess, 'run', side_effect=run):
            self.assertFalse(wallpaper.apply_wallpaper(image))
        self.assertEqual(existing.read_text(), 'old theme')
        self.assertFalse(created.exists())
        self.assertEqual(wallpaper.CURRENT.resolve(), old)

    def test_click_selects_full_frame_and_drag_handles_scale(self):
        capture = load('capture')
        self.assertEqual(capture.selection_bounds((100, 100), (101, 101), (960, 540), (1920, 1080)), (0, 0, 1920, 1080))
        self.assertEqual(capture.selection_bounds((150, 200), (50, 100), (960, 540), (1920, 1080)), (100, 200, 200, 200))
        self.assertEqual(capture.selection_bounds((-10, -10), (1000, 600), (960, 540), (1920, 1080)), (0, 0, 1920, 1080))

    def test_workspace_events_keep_active_and_focused_outputs_distinct(self):
        workspaces = load('workspace-status')
        state = [{'id': 1, 'name': '1', 'output': 'one', 'is_active': True, 'is_focused': True, 'active_window_id': None},
                 {'id': 2, 'name': '2', 'output': 'two', 'is_active': True, 'is_focused': False, 'active_window_id': 7}]
        state = workspaces.update(state, {'WorkspaceActivated': {'id': 2, 'focused': True}})
        self.assertEqual(workspaces.status(state, '1')['class'], ['active', 'empty'])
        self.assertEqual(workspaces.status(state, '2')['class'], ['active', 'focused'])

    @unittest.skipUnless(shutil.which('magick'), 'ImageMagick is required')
    def test_bundled_portrait_preserves_transparent_canvas(self):
        with patch.dict(os.environ, {'SWEET_POOL_CG_DIR': ''}), patch.object(sys, 'argv', ['prepare-fastfetch-logo.py', 'makoto-junk-food.jpg']):
            portrait = load('prepare-fastfetch-logo')
        portrait.SPRITES.mkdir(parents=True)
        for source in (ROOT / 'assets/fastfetch-logos').glob('*.png'):
            shutil.copy2(source, portrait.SPRITES / source.name)
        portrait.main()
        image = portrait.OUTPUT / 'fastfetch-portrait.png'
        pixel = subprocess.check_output(['magick', str(image), '-format', '%[pixel:p{0,0}]', 'info:'], text=True)
        self.assertTrue(pixel.endswith(',0)'), pixel)

    def test_panel_stops_after_three_rapid_failures_and_logs_exit(self):
        panel = load('panel')
        with patch.object(panel, 'running', return_value=[]), patch.object(panel.time, 'sleep'), \
             patch.object(panel.subprocess, 'run', return_value=subprocess.CompletedProcess(['waybar'], -11)) as launch:
            panel.supervise()
        self.assertEqual(launch.call_count, 3)
        log = (self.home / '.local/state/sweet-dots/waybar.log').read_text()
        self.assertIn('Waybar exited: -11', log)
        self.assertIn('three rapid failures', log)


if __name__ == '__main__':
    unittest.main()
