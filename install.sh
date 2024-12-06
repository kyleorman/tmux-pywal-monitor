#!/usr/bin/env bash

set -euo pipefail

# Configuration
INSTALL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/tmux-pywal-monitor"
SERVICE_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-pywal-monitor"
BIN_DIR="${HOME}/.local/bin"

# Create necessary directories
mkdir -p "$INSTALL_DIR" "$SERVICE_DIR" "$CONFIG_DIR" "$BIN_DIR"

# Install monitor script
cat > "$BIN_DIR/tmux-statusline-monitor" << 'EOL'
#!/usr/bin/env bash

set -euo pipefail

# Source configuration
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-pywal-monitor/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

# Default configuration values
TMUX_CONF="${TMUX_CONF:-$HOME/.tmuxline.conf}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
COLORS_FILE="${COLORS_FILE:-$CACHE_DIR/wal/colors.json}"
VIM_LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/tmux-statusline-monitor"
LOCK_FILE="$VIM_LOCK_DIR/vim-controlled"
UPDATE_INTERVAL="${UPDATE_INTERVAL:-5}"

mkdir -p "$VIM_LOCK_DIR"

check_vim_control() {
    [[ -f "$LOCK_FILE" ]]
}

check_vim_sessions() {
    local tmux_sessions
    tmux_sessions=$(tmux list-sessions -F '#{session_name}' 2>/dev/null)
    
    for session in $tmux_sessions; do
        if tmux list-panes -t "$session" -F '#{pane_current_command}' | grep -q "vim\|nvim"; then
            return 0
        fi
    done
    return 1
}

generate_tmux_colors() {
    if check_vim_control || check_vim_sessions; then
        return
    fi
    
    local colors
    colors=$(cat "$COLORS_FILE")
    
    if [[ ! -f "$TMUX_CONF.backup" ]]; then
        cp "$TMUX_CONF" "$TMUX_CONF.backup"
    fi
    
    local background foreground accent message_bg
    background=$(echo "$colors" | jq -r '.special.background')
    foreground=$(echo "$colors" | jq -r '.special.foreground')
    accent=$(echo "$colors" | jq -r '.colors.color2')
    message_bg=$(echo "$colors" | jq -r '.colors.color8')
    
    # Generate tmux configuration preserving tmuxline.vim structure
    sed -e "s/bg=#[0-9a-fA-F]\{6\}/bg=$background/g" \
        -e "s/fg=#[0-9a-fA-F]\{6\}/fg=$foreground/g" \
        "$TMUX_CONF.backup" > "$TMUX_CONF"

    if tmux list-sessions &>/dev/null; then
        tmux source-file "$TMUX_CONF"
    fi
}

cleanup() {
    if [[ -f "$TMUX_CONF.backup" ]] && ! check_vim_control; then
        mv "$TMUX_CONF.backup" "$TMUX_CONF"
        tmux source-file "$TMUX_CONF" 2>/dev/null
    fi
    exit 0
}

trap cleanup SIGTERM SIGINT

# Main monitoring loop
LAST_MODIFIED=0

while true; do
    if [[ -f "$COLORS_FILE" ]]; then
        current_modified=$(stat -c %Y "$COLORS_FILE")
        if (( current_modified > LAST_MODIFIED )); then
            generate_tmux_colors
            LAST_MODIFIED=$current_modified
        fi
    fi
    sleep "$UPDATE_INTERVAL"
done
EOL

chmod +x "$BIN_DIR/tmux-statusline-monitor"

# Install restore script
cat > "$BIN_DIR/tmux-statusline-restore" << 'EOL'
#!/usr/bin/env bash

set -euo pipefail

CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/tmux-pywal-monitor/config.sh"
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
fi

TMUX_CONF="${TMUX_CONF:-$HOME/.tmuxline.conf}"

if [[ -f "$TMUX_CONF.backup" ]]; then
    mv "$TMUX_CONF.backup" "$TMUX_CONF"
    tmux source-file "$TMUX_CONF" 2>/dev/null
fi
EOL

chmod +x "$BIN_DIR/tmux-statusline-restore"

# Install systemd service
cat > "$SERVICE_DIR/tmux-statusline-monitor.service" << EOF
[Unit]
Description=Tmux Statusline Pywal Monitor
After=graphical-session.target

[Service]
Type=simple
Environment=DISPLAY=:0
ExecStart=$BIN_DIR/tmux-statusline-monitor
ExecStopPost=$BIN_DIR/tmux-statusline-restore
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

# Create default configuration
cat > "$CONFIG_DIR/config.sh" << 'EOF'
# Tmux Statusline Monitor Configuration

# Path to tmux configuration file
TMUX_CONF="$HOME/.tmuxline.conf"

# Path to pywal colors file
COLORS_FILE="$HOME/.cache/wal/colors.json"

# Update interval in seconds
UPDATE_INTERVAL=5
EOF

# Enable and start the service
systemctl --user daemon-reload
systemctl --user enable tmux-statusline-monitor
systemctl --user start tmux-statusline-monitor

echo "Tmux Statusline Monitor has been installed and started."
echo "Configuration file: $CONFIG_DIR/config.sh"
echo "Service status: systemctl --user status tmux-statusline-monitor"
