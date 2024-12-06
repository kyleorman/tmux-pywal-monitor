#!/usr/bin/env bash

set -euo pipefail

SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-pywal-monitor"
BIN_DIR="${HOME}/.local/bin"

systemctl --user stop tmux-statusline-monitor.service || true
systemctl --user disable tmux-statusline-monitor.service || true

rm -f "$SERVICE_DIR/tmux-statusline-monitor.service"
rm -f "$BIN_DIR/tmux-statusline-monitor"
rm -f "$BIN_DIR/tmux-statusline-restore"

# Optionally, remove configuration:
# rm -rf "$CONFIG_DIR"

systemctl --user daemon-reload

echo "Tmux Statusline Monitor uninstalled."
