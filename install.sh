#!/usr/bin/env bash

set -euo pipefail

# Directories (XDG-compliant)
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-pywal-monitor"
SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-pywal-monitor"
BIN_DIR="${HOME}/.local/bin"

# Create directories
mkdir -p "$INSTALL_DIR" "$SERVICE_DIR" "$CONFIG_DIR" "$BIN_DIR"

# Copy scripts
cp bin/tmux-statusline-monitor "$BIN_DIR/"
cp bin/tmux-statusline-restore "$BIN_DIR/"

chmod +x "$BIN_DIR/tmux-statusline-monitor"
chmod +x "$BIN_DIR/tmux-statusline-restore"

# Copy service file
cp service/tmux-statusline-monitor.service "$SERVICE_DIR/"
# If you modify paths in the service file, ensure ExecStart/ExecStopPost paths match.

# Install configuration if not present
if [[ ! -f "$CONFIG_DIR/config.sh" ]]; then
    cp config/config.template.sh "$CONFIG_DIR/config.sh"
    echo "Configuration file created at $CONFIG_DIR/config.sh"
fi

systemctl --user daemon-reload
systemctl --user enable tmux-statusline-monitor.service
systemctl --user start tmux-statusline-monitor.service

echo "Tmux Statusline Monitor installed and started."
echo "Check service status: systemctl --user status tmux-statusline-monitor.service"
