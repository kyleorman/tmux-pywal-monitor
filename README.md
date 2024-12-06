# Tmux Statusline Monitor

A service that automatically synchronizes your tmux status line with pywal colors while maintaining compatibility with Vim/Neovim statusline plugins.

## Features

- Automatic synchronization with pywal color schemes
- Seamless integration with vim-airline and tmuxline.vim
- Intelligent handling of Vim/Neovim sessions
- Systemd user service for reliable operation
- XDG Base Directory compliance
- Configuration persistence

## Prerequisites

- tmux (version 2.9 or higher)
- pywal
- systemd
- jq
- bash (version 4.0 or higher)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/kyleorman/tmux-pywal-monitor
   cd tmux-pywal-monitor
   ```

2. Run the installation script:
   ```bash
   ./install.sh
   ```

The installer will:
- Set up the monitoring service
- Configure systemd user service
- Create default configuration
- Start the service automatically

## Configuration

Edit the configuration file at `~/.config/tmux-pywal-monitor/config.sh`:

```bash
# Path to tmux configuration file
TMUX_CONF="$HOME/.tmuxline.conf"

# Path to pywal colors file
COLORS_FILE="$HOME/.cache/wal/colors.json"

# Update interval in seconds
UPDATE_INTERVAL=5
```

## Integration with Vim Plugins

The service automatically detects when Vim is running and defers control to your Vim statusline plugins. This ensures that plugins like vim-airline and tmuxline.vim work correctly while maintaining pywal integration when Vim is not active.

To integrate with vim-statusline-themer or similar plugins, ensure they manage the lockfile at `$XDG_RUNTIME_DIR/tmux-statusline-monitor/vim-controlled` when taking control of the statusline.

## Usage

The service runs automatically in the background. You can manage it using:

```bash
# Check status
systemctl --user status tmux-statusline-monitor

# Restart service
systemctl --user restart tmux-statusline-monitor

# Stop service
systemctl --user stop tmux-statusline-monitor

# View logs
journalctl --user -u tmux-statusline-monitor
```

## Troubleshooting

1. Check service status:
   ```bash
   systemctl --user status tmux-statusline-monitor
   ```

2. View service logs:
   ```bash
   journalctl --user -u tmux-statusline-monitor
   ```

3. Verify file permissions:
   ```bash
   ls -l ~/.local/bin/tmux-statusline-monitor
   ls -l ~/.config/tmux-pywal-monitor/config.sh
   ```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

`themer.vim` is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.

## Support

For issues, questions, or contributions:
1. Check existing issues on GitHub
2. Create a new issue
3. Include relevant system information and logs
